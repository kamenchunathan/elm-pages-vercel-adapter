module Route.Contact exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes as Attributes
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    {}


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.succeed {}


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "The Station News"
        , image =
            { url = [ "images", "icon-png.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "The Station News Logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Contact The Station News"
        , locale = Nothing
        , title = "Contact Us"
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view _ _ =
    { title = "Contact Us"
    , body =
        [ h1 [ Attributes.class "text-4xl font-bold mb-4" ] [ text "Contact Us" ]
        , p [ Attributes.class "text-lg mb-4" ] [ text "We'd love to hear from you." ]
        , div []
            [ h2 [ Attributes.class "text-2xl font-bold mb-2" ] [ text "Email" ]
            , p [ Attributes.class "mb-4" ] [ text "contact@thestation.news" ]
            , h2 [ Attributes.class "text-2xl font-bold mb-2" ] [ text "Phone" ]
            , p [ Attributes.class "mb-4" ] [ text "+1 (555) 123-4567" ]
            ]
        ]
    }
