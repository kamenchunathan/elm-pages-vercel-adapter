module Route.Journal.SPLAT__ exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import BackendTask
import Effect
import FatalError
import Head
import Html
import PagesMsg
import RouteBuilder
import Shared
import UrlPath
import View


type alias Model =
    {}


type Msg
    = NoOp


type alias RouteParams =
    { splat : List String }


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
    {}


type alias ActionData =
    BackendTask.BackendTask FatalError.FatalError (List RouteParams)


data : RouteParams -> BackendTask.BackendTask error {}
data routeParams =
    BackendTask.succeed {}


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "Journal.SPLAT__"
    , body = [ Html.h2 [] [ Html.text "New Page" ] ]
    }


pages : BackendTask.BackendTask FatalError.FatalError (List RouteParams)
pages =
    BackendTask.succeed
        [ { splat = [] }
        , { splat = [ "2021", "june", "Tue, 11" ] }
        , { splat = [ "2021", "june", "Wed, 12" ] }
        ]
