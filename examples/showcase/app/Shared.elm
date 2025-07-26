module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import BackendTask exposing (BackendTask)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Svg
import Svg.Attributes as SvgAttr
import UrlPath exposing (UrlPath)
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Nothing
    }


type Msg
    = SharedMsg SharedMsg
    | MenuClicked


type alias Data =
    ()


type SharedMsg
    = NoOp


type alias Model =
    { showMenu : Bool
    }


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : UrlPath
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init flags maybePagePath =
    ( { showMenu = False }
    , Effect.none
    )


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SharedMsg globalMsg ->
            ( model, Effect.none )

        MenuClicked ->
            ( { model | showMenu = not model.showMenu }, Effect.none )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


view :
    Data
    ->
        { path : UrlPath
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : List (Html msg), title : String }
view sharedData page model toMsg pageView =
    { body =
        [ header [ class "flex items-center justify-between flex-wrap bg-gray-800 p-6" ]
            [ Route.link [ class "flex items-center flex-shrink-0 text-white mr-6" ]
                [ h1 [ class "font-semibold text-xl tracking-tight" ] [ text "My Site" ] ]
                Route.Index
            , div [ class "block lg:hidden" ]
                [ button
                    [ class "flex items-center px-3 py-2 border rounded text-teal-200 border-teal-400 hover:text-white hover:border-white"
                    , Html.Events.onClick (toMsg MenuClicked)
                    ]
                    [ Svg.svg [ SvgAttr.class "fill-current h-3 w-3", SvgAttr.viewBox "0 0 20 20", SvgAttr.name "http://www.w3.org/2000/svg" ]
                        [ Svg.title [] [ text "Menu" ]
                        , Svg.path [ SvgAttr.d "M0 3h20v2H0V3zm0 6h20v2H0V9zm0 6h20v2H0v-2z" ] []
                        ]
                    ]
                ]
            , div
                [ classList [ ( "w-full flex-grow lg:flex lg:items-center lg:w-auto justify-end", True ), ( "hidden", not model.showMenu ) ]
                , class "lg:!flex"
                ]
                [ Route.link [ HA.class "block mt-4 lg:hidden text-teal-200 hover:text-white mr-4" ] [ text "Home" ] Route.Index
                , Route.link [ class "block mt-4 lg:inline-block lg:mt-0 text-teal-200 hover:text-white mr-4" ] [ text "About" ] Route.About
                , Route.link [ class "block mt-4 lg:inline-block lg:mt-0 text-teal-200 hover:text-white" ] [ text "Archive" ] Route.Archive
                ]
            ]
        , main_
            [ class "container mx-auto px-4 flex-grow" ]
            pageView.body
        , footer [ class "bg-gray-800 text-white p-4 mt-8" ]
            [ div [ class "container mx-auto text-center" ]
                [ p [] [ text "© 2025 My Site. All rights reserved." ]
                , div [ class "flex justify-center space-x-4 mt-2" ]
                    [ a [ href "#", class "hover:text-teal-200" ] [ text "Legal" ]
                    , a [ href "#", class "hover:text-teal-200" ] [ text "Socials" ]
                    ]
                ]
            ]
        ]
    , title = pageView.title
    }

