module Route.Archive.SPLAT_ exposing (Model, Msg, RouteParams, route, Data, ActionData)

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
    { splat : ( String, List String ) }


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
    { title = "Archive.SPLAT_", body = [ Html.h2 [] [ Html.text "New Page" ] ] }


pages : BackendTask.BackendTask FatalError.FatalError (List RouteParams)
pages =
    BackendTask.succeed
        [ { splat = ( "packages", [ "react", "v16.8.0", "react-16.8.0.tar.gz" ] ) }
        , { splat = ( "packages", [ "react", "v17.0.2", "react-17.0.2.tar.gz" ] ) }
        , { splat = ( "packages", [ "vue", "v3.0.0", "vue-3.0.0.zip" ] ) }
        , { splat = ( "packages", [ "vue", "v3.1.1", "vue-3.1.1.zip" ] ) }
        , { splat = ( "packages", [ "angular", "v10.0.0", "angular-10.0.0.tar.gz" ] ) }
        , { splat = ( "packages", [ "angular", "v11.2.11", "angular-11.2.11.tar.gz" ] ) }
        , { splat = ( "packages", [ "bootstrap", "v4.5.2", "bootstrap-4.5.2.zip" ] ) }
        , { splat = ( "packages", [ "bootstrap", "v5.1.0", "bootstrap-5.1.0.zip" ] ) }
        , { splat = ( "packages", [ "jquery", "v3.5.1", "jquery-3.5.1.tar.gz" ] ) }
        , { splat = ( "packages", [ "jquery", "v3.6.0", "jquery-3.6.0.tar.gz" ] ) }
        , { splat = ( "packages", [ "lodash", "v4.17.21", "lodash-4.17.21.zip" ] ) }
        , { splat = ( "packages", [ "lodash", "v4.17.22", "lodash-4.17.22.zip" ] ) }
        , { splat = ( "packages", [ "express", "v4.17.1", "express-4.17.1.tar.gz" ] ) }
        , { splat = ( "packages", [ "express", "v5.0.0", "express-5.0.0.tar.gz" ] ) }
        , { splat = ( "packages", [ "mongodb", "v4.4.3", "mongodb-4.4.3.tar.gz" ] ) }
        , { splat = ( "packages", [ "mongodb", "v5.0.0", "mongodb-5.0.0.tar.gz" ] ) }
        , { splat = ( "packages", [ "webpack", "v5.44.0", "webpack-5.44.0.zip" ] ) }
        , { splat = ( "packages", [ "webpack", "v6.0.0", "webpack-6.0.0.zip" ] ) }
        , { splat = ( "packages", [ "axios", "v0.21.1", "axios-0.21.1.tar.gz" ] ) }
        , { splat = ( "packages", [ "axios", "v0.22.0", "axios-0.22.0.tar.gz" ] ) }
        ]

