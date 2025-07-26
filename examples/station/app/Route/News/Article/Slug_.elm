module Route.News.Article.Slug_ exposing (ActionData, Data, Model, Msg, route)

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
import RouteBuilder exposing (App, StatelessRoute)
import Server.Response
import Shared
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { slug : String }


type alias Data =
    { story : Database.NewsStory
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRenderWithFallback
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


pages : BackendTask FatalError (List RouteParams)
pages =
    Database.getNewsSlugs
        |> List.map (\slug -> { slug = slug })
        |> BackendTask.succeed


data : RouteParams -> BackendTask FatalError (Server.Response.Response Data ErrorPage)
data { slug } =
    Database.getNewsBySlug slug
        |> Maybe.map (\story -> Server.Response.render { story = story })
        |> Maybe.withDefault (Server.Response.errorPage ErrorPage.NotFound)
        |> BackendTask.succeed


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "The Station News"
        , image =
            { url = [ "images", "icon-png.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "The Station News Logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = app.data.story.summary
        , locale = Nothing
        , title = app.data.story.title
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app _ =
    { title = app.data.story.title
    , body =
        [ h1 [ Attributes.class "text-4xl font-bold mb-2 text-gray-800" ] [ text app.data.story.title ]
        , p [ Attributes.class "text-gray-600 mb-4" ]
            [ text ("By " ++ app.data.story.author ++ " on " ++ app.data.story.publishedDate) ]
        , article [ Attributes.class "prose lg:prose-xl max-w-none" ]
            [ p [] [ text app.data.story.body ]
            ]
        ]
    }
