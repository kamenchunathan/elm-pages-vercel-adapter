module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Database
import ErrorPage exposing (ErrorPage)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes as Attributes
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Server.Request exposing (Request)
import Server.Response as Response exposing (Response)
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
    { topNews : List Database.NewsStory
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.serverRender
        { head = head
        , data = data
        , action = \_ _ -> BackendTask.fail (FatalError.fromString "No action.")
        }
        |> RouteBuilder.buildNoState { view = view }


data : RouteParams -> Request -> BackendTask FatalError (Response Data ErrorPage)
data _ _ =
    BackendTask.succeed { topNews = Database.topNews }
        |> BackendTask.map Response.render


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
        , description = "The latest news, served fresh."
        , locale = Nothing
        , title = "The Station"
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app _ =
    { title = "The Station"
    , body =
        [ h1 [ Attributes.class "text-4xl font-bold mb-4 text-gray-800" ] [ text "Top Stories" ]
        , ul [ Attributes.class "space-y-8" ]
            (List.map
                (\news ->
                    li [ Attributes.class "bg-white shadow-lg rounded-lg p-6 hover:shadow-xl transition-shadow duration-300" ]
                        [ h3 [ Attributes.class "text-2xl font-bold mb-2" ]
                            [ Route.News__Article__Slug_ { slug = news.slug }
                                |> Route.link [ Attributes.class "text-blue-600 hover:underline" ] [ text news.title ]
                            ]
                        , p [ Attributes.class "text-gray-600" ] [ text news.summary ]
                        ]
                )
                app.data.topNews
            )
        ]
    }
