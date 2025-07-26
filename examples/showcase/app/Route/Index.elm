module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.File
import BackendTask.Glob as Glob
import GlobPatterns
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (div, h1, h2, li, p, text, ul)
import Html.Attributes exposing (class)
import Iso8601
import Json.Decode as Decode
import Json.Encode as Encode
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Time
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Post =
    { title : String
    , date : Time.Posix
    , slug : String
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


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }





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
    Decode.map2
        (\title date ->
            { title = title
            , date = date
            , slug = slug
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


journalDecoder : String -> Decode.Decoder Journal
journalDecoder slug =
    Decode.map
        (\title -> { title = title, slug = slug })
        (Decode.field "title" Decode.string)


data : BackendTask FatalError Data
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


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "My Blog"
        , image =
            { url = [ "images", "icon-png.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Welcome to my blog!"
        , locale = Nothing
        , title = "Home"
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app _ =
    { title = "Home"
    , body =
        [ div [ class "text-center py-12" ]
            [ h1 [ class "text-4xl font-bold" ] [ text "Welcome to My Awesome Site" ]
            , p [ class "text-xl mt-4 text-gray-600" ] [ text "A place for thoughts, stories, and ideas." ]
            ]
        , h2 [ class "text-2xl font-bold mb-4" ] [ text "Recent Posts" ]
        , ul [ class "list-disc pl-5" ]
            (List.map
                (\post ->
                    li []
                        [ Route.Blog__Slug_ { slug = post.slug }
                            |> Route.link [ class "text-blue-500 hover:underline" ] [ text post.title ]
                        ]
                )
                app.data.posts
            )
        , h2 [ class "text-2xl font-bold mt-8 mb-4" ] [ text "Recent Journals" ]
        , ul [ class "list-disc pl-5" ]
            (List.map
                (\journal ->
                    li []
                        [ Route.Journal__Slug_ { slug = journal.slug }
                            |> Route.link [ class "text-blue-500 hover:underline" ] [ text journal.title ]
                        ]
                )
                app.data.journals
            )
        ]
    }
