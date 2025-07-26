module Route.Journal.Slug_ exposing (ActionData, Data, Model, Msg, RouteParams, route)

import BackendTask exposing (BackendTask)
import BackendTask.File
import BackendTask.Glob as Glob
import GlobPatterns
import Effect
import FatalError exposing (FatalError)
import Head
import Html as H
import Html.Attributes as Attr
import Json.Decode as Decode
import Markdown.Parser
import Markdown.Renderer
import PagesMsg exposing (PagesMsg)
import RouteBuilder
import Shared
import UrlPath
import View


type alias Model =
    {}


type Msg
    = NoOp


type alias RouteParams =
    { slug : String }


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.preRender
        { data = data
        , pages = pages
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


type alias Data =
    { title : String, body : String }


type alias ActionData =
    {}





pages : BackendTask.BackendTask FatalError.FatalError (List RouteParams)
pages =
    GlobPatterns.journalPostsGlob
        |> BackendTask.map (List.map (\journal -> { slug = journal.slug }))


fatalErrorFromFileError : String -> { fatal : FatalError, recoverable : BackendTask.File.FileReadError Decode.Error } -> FatalError
fatalErrorFromFileError filePath error =
    case error.recoverable of
        BackendTask.File.FileDoesntExist ->
            FatalError.fromString ("File doesn't exist: " ++ filePath)

        BackendTask.File.FileReadError reason ->
            FatalError.fromString ("File read error for " ++ filePath ++ ": " ++ reason)

        BackendTask.File.DecodingError decodeError ->
            FatalError.fromString ("Error decoding frontmatter in " ++ filePath ++ ": " ++ Decode.errorToString decodeError)


journalDetailsDecoder : String -> Decode.Decoder Data
journalDetailsDecoder body =
    Decode.map
        (\title -> { title = title, body = body })
        (Decode.field "title" Decode.string)


data : RouteParams -> BackendTask.BackendTask FatalError.FatalError Data
data routeParams =
    let
        filePath : String
        filePath =
            "content/journal/" ++ routeParams.slug ++ ".md"
    in
    BackendTask.File.bodyWithFrontmatter
        journalDetailsDecoder
        filePath
        |> BackendTask.mapError (fatalErrorFromFileError filePath)


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    []


markdownToHtml : String -> List (H.Html msg)
markdownToHtml markdownString =
    case
        markdownString
            |> Markdown.Parser.parse
            |> Result.mapError (\_ -> "Markdown error.")
            |> Result.andThen
                (\blocks ->
                    Markdown.Renderer.render
                        Markdown.Renderer.defaultHtmlRenderer
                        blocks
                )
    of
        Ok html ->
            html

        Err _ ->
            []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg Msg)
view app shared model =
    { title = app.data.title
    , body =
        [ H.main_ [ Attr.id "markdown-content", Attr.class "prose lg:prose-xl mx-auto py-8 journal-content" ]
            (markdownToHtml app.data.body)
        ]
    }
