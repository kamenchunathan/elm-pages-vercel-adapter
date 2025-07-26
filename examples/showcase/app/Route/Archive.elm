module Route.Archive exposing (ActionData, Data, Model, Msg, RouteParams, route)

import BackendTask
import BackendTask.File
import Effect
import FatalError exposing (FatalError)
import GlobPatterns
import Head
import Html
import Html.Attributes exposing (class)
import Iso8601
import Json.Decode as Decode
import Json.Encode as Encode
import List.Extra
import PagesMsg
import Route
import RouteBuilder
import Shared
import Time
import UrlPath
import View


type alias Model =
    {}


type Msg
    = NoOp


type alias RouteParams =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { data = data
        , head = head
        }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init app shared =
    ( {}, Effect.none )


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update app shared msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


type alias Post =
    { title : String
    , slug : String
    , date : Time.Posix
    , tags : List String
    }


type alias Journal =
    { title : String
    , slug : String
    }


type alias Data =
    { posts : List Post
    , journals : List Journal
    }


type alias ActionData =
    {}


fatalErrorFromFileError : String -> { fatal : FatalError, recoverable : BackendTask.File.FileReadError Decode.Error } -> FatalError
fatalErrorFromFileError filePath error =
    case error.recoverable of
        BackendTask.File.FileDoesntExist ->
            FatalError.fromString ("File doesn't exist: " ++ filePath)

        BackendTask.File.FileReadError reason ->
            FatalError.fromString ("File read error for " ++ filePath ++ ": " ++ reason)

        BackendTask.File.DecodingError decodeError ->
            FatalError.fromString ("Error decoding frontmatter in " ++ filePath ++ ": " ++ Decode.errorToString decodeError)


postDecoder : String -> Decode.Decoder Post
postDecoder slug =
    Decode.map3
        (\title date tags ->
            { title = title
            , slug = slug
            , date = date
            , tags = tags
            }
        )
        (Decode.field "title" Decode.string)
        (Decode.field "date" Decode.value
            |> Decode.andThen
                (Encode.encode 0
                    >> Decode.decodeString Decode.string
                    >> Result.toMaybe
                    >> Maybe.andThen
                        (Iso8601.toTime >> Result.toMaybe >> Maybe.map Decode.succeed)
                    >> Maybe.withDefault
                        (Decode.fail "Could not parse the date field, Ensure it is formatted as an iso 8601 string")
                )
        )
        (Decode.field "tags" (Decode.list Decode.string))


journalDecoder : String -> Decode.Decoder Journal
journalDecoder slug =
    Decode.map
        (\title -> { title = title, slug = slug })
        (Decode.field "title" Decode.string)


data : BackendTask.BackendTask FatalError.FatalError Data
data =
    BackendTask.map2
        (\posts journals -> { posts = posts, journals = journals })
        (GlobPatterns.blogPostsGlob
            |> BackendTask.andThen
                (\files ->
                    files
                        |> List.map
                            (\file ->
                                BackendTask.File.onlyFrontmatter
                                    (postDecoder file.slug)
                                    file.filePath
                                    |> BackendTask.mapError (fatalErrorFromFileError file.filePath)
                            )
                        |> BackendTask.combine
                )
            |> BackendTask.map
                (List.sortWith
                    (\a b -> compare (Time.posixToMillis b.date) (Time.posixToMillis a.date))
                )
        )
        (GlobPatterns.journalPostsGlob
            |> BackendTask.andThen
                (\files ->
                    files
                        |> List.map
                            (\file ->
                                BackendTask.File.onlyFrontmatter
                                    (journalDecoder file.slug)
                                    file.filePath
                                    |> BackendTask.mapError (fatalErrorFromFileError file.filePath)
                            )
                        |> BackendTask.combine
                )
        )


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view : RouteBuilder.App Data ActionData RouteParams -> Shared.Model -> Model -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    let
        postsByYearAndMonth =
            app.data.posts
                |> List.Extra.groupWhile
                    (\post1 post2 -> Time.toYear Time.utc post1.date == Time.toYear Time.utc post2.date)
                |> List.map
                    (\( prototype, postsInYear ) ->
                        ( Time.toYear Time.utc prototype.date
                        , postsInYear
                            |> List.Extra.groupWhile
                                (\post1 post2 -> Time.toMonth Time.utc post1.date == Time.toMonth Time.utc post2.date)
                            |> List.map
                                (\( monthPrototype, postsInMonth ) ->
                                    ( Time.toMonth Time.utc monthPrototype.date
                                    , postsInMonth
                                    )
                                )
                        )
                    )
    in
    { title = "Archive"
    , body =
        [ Html.h1 [ class "text-3xl font-bold mb-4 mt-8" ] [ Html.text "Archive" ]
        , Html.h2 [ class "text-2xl font-bold mt-8 mb-4" ] [ Html.text "Blog Posts" ]
        , Html.div []
            (List.map
                (\( year, months ) ->
                    Html.div []
                        [ Html.h3 [ class "text-xl font-semibold mt-6 mb-2" ] [ Html.text (String.fromInt year) ]
                        , Html.div []
                            (List.map
                                (\( month, posts ) ->
                                    Html.div []
                                        [ Html.h4 [ class "text-lg font-medium mt-4 mb-1" ] [ Html.text (monthToString month) ]
                                        , Html.ul [ class "list-none space-y-4" ]
                                            (List.map
                                                (\post ->
                                                    Html.li [ class "p-4 bg-slate-100 rounded-md" ]
                                                        [ Route.Blog__Slug_ { slug = post.slug }
                                                            |> Route.link [ class "text-xl font-semibold text-blue-950 hover:underline" ] [ Html.text post.title ]
                                                        , Html.div [ class "mt-1 space-x-4" ]
                                                            (List.map
                                                                (\tag ->
                                                                    Html.span [ class "inline-block px-2 py-1 rounded-full bg-blue-100 text-gray-700 text-xs mr-1" ]
                                                                        [ Html.text ("# " ++ tag) ]
                                                                )
                                                                post.tags
                                                            )
                                                        ]
                                                )
                                                posts
                                            )
                                        ]
                                )
                                months
                            )
                        ]
                )
                postsByYearAndMonth
            )
        , Html.h2 [ class "text-2xl font-bold mt-8 mb-4" ] [ Html.text "Journal Entries" ]
        , Html.ul [ class "list-none" ]
            (List.map
                (\journal ->
                    Html.li [ class "mb-4" ]
                        [ Route.Journal__Slug_ { slug = journal.slug }
                            |> Route.link [ class "text-blue-500 hover:underline" ] [ Html.text journal.title ]
                        ]
                )
                app.data.journals
            )
        ]
    }


monthToString : Time.Month -> String
monthToString month =
    case month of
        Time.Jan ->
            "January"

        Time.Feb ->
            "February"

        Time.Mar ->
            "March"

        Time.Apr ->
            "April"

        Time.May ->
            "May"

        Time.Jun ->
            "June"

        Time.Jul ->
            "July"

        Time.Aug ->
            "August"

        Time.Sep ->
            "September"

        Time.Oct ->
            "October"

        Time.Nov ->
            "November"

        Time.Dec ->
            "December"
