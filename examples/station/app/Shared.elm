module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import BackendTask exposing (BackendTask)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
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
init _ _ =
    ( { showMenu = False }
    , Effect.none
    )


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SharedMsg _ ->
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
view _ _ model toMsg pageView =
    { body =
        [ Html.div [ Attributes.class "bg-gray-50 font-sans leading-normal tracking-normal min-h-screen flex flex-col" ]
            [ headerView model toMsg
            , Html.main_ [ Attributes.class "container mx-auto py-8 flex-grow" ] pageView.body
            , footerView
            ]
        ]
    , title = pageView.title
    }


headerView : Model -> (Msg -> msg) -> Html msg
headerView model toMsg =
    Html.nav [ Attributes.class "bg-blue-600 shadow-lg" ]
        [ Html.div [ Attributes.class "container mx-auto px-6 py-4" ]
            [ Html.div [ Attributes.class "flex items-center justify-between" ]
                [ Html.div []
                    [ Route.Index |> Route.link [ Attributes.class "text-2xl font-bold text-white lg:text-3xl hover:text-gray-200" ] [ Html.text "The Station" ]
                    ]
                , Html.div [ Attributes.class "hidden md:flex items-center" ]
                    [ Route.Index |> Route.link [ Attributes.class "px-4 py-2 text-white hover:text-gray-200" ] [ Html.text "Home" ]
                    , Route.About |> Route.link [ Attributes.class "px-4 py-2 text-white hover:text-gray-200" ] [ Html.text "About" ]
                    , Route.Contact |> Route.link [ Attributes.class "px-4 py-2 text-white hover:text-gray-200" ] [ Html.text "Contact" ]
                    , Route.Games__Puzzle |> Route.link [ Attributes.class "px-4 py-2 text-white hover:text-gray-200" ] [ Html.text "Puzzle" ]
                    , Route.Games__Sudoku |> Route.link [ Attributes.class "px-4 py-2 text-white hover:text-gray-200" ] [ Html.text "Sudoku" ]
                    ]
                , Html.div [ Attributes.class "md:hidden" ]
                    [ Html.button [ Attributes.class "text-white focus:outline-none", Html.Events.onClick (toMsg MenuClicked) ]
                        [ Html.text "Menu" ]
                    ]
                ]
            , if model.showMenu then
                Html.div [ Attributes.class "md:hidden mt-4" ]
                    [ Route.Index |> Route.link [ Attributes.class "block px-4 py-2 text-white hover:bg-blue-700" ] [ Html.text "Home" ]
                    , Route.About |> Route.link [ Attributes.class "block px-4 py-2 text-white hover:bg-blue-700" ] [ Html.text "About" ]
                    , Route.Contact |> Route.link [ Attributes.class "block px-4 py-2 text-white hover:bg-blue-700" ] [ Html.text "Contact" ]
                    , Route.Games__Puzzle |> Route.link [ Attributes.class "block px-4 py-2 text-white hover:bg-blue-700" ] [ Html.text "Puzzle" ]
                    , Route.Games__Sudoku |> Route.link [ Attributes.class "block px-4 py-2 text-white hover:bg-blue-700" ] [ Html.text "Sudoku" ]
                    ]

              else
                Html.div [] []
            ]
        ]


footerView : Html msg
footerView =
    Html.footer [ Attributes.class "bg-blue-600 mt-8" ]
        [ Html.div [ Attributes.class "container mx-auto px-6 py-4" ]
            [ Html.div [ Attributes.class "flex justify-between items-center" ]
                [ Html.p [ Attributes.class "text-white" ] [ Html.text "© 2025 The Station News" ]
                ]
            ]
        ]
