module Route.Blog.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import ErrorPage exposing (ErrorPage)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Server.Response as Response exposing (Response)
import Shared
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { slug : String }


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
    BackendTask.succeed
        [ { slug = "Eating the elephant" }
        , { slug = "Religion and Schools" }
        ]


type alias Data =
    { something : String
    }


type alias ActionData =
    {}


pastaBlog : String
pastaBlog =
    """The Culinary Journey of Pasta: A Timeless Delight
Pasta, a culinary masterpiece cherished by millions around the world, transcends mere food—it embodies culture, history, and tradition on a plate. From its humble beginnings in ancient civilizations to its global popularity today, pasta has woven itself into the fabric of culinary heritage, captivating hearts and palates with its versatility and charm.
A Rich Tapestry of History
The origins of pasta can be traced back to ancient times, with evidence of its existence found in various cultures across the globe. However, it was the Italians who elevated pasta-making to an art form. The earliest documented reference to pasta dates back to the 1st century AD, mentioned by the Roman poet Horace. Over the centuries, pasta evolved from a simple staple to a symbol of Italian identity and culinary prowess.
The Craft of Pasta-Making
At the heart of pasta lies simplicity—just flour, water, and sometimes eggs. Yet, within this basic framework lies a world of culinary possibilities. Pasta dough is kneaded, rolled, and shaped into a myriad of forms, each with its own texture and character. From the delicate folds of ravioli to the long strands of spaghetti, pasta shapes offer endless opportunities for creativity and expression.
Traditional pasta-making techniques have been passed down through generations, with artisanal producers preserving the integrity of age-old recipes. However, modern innovations have also revolutionized the pasta industry, with advanced machinery streamlining production processes while maintaining the quality and authenticity of the final product.
Pasta: A Global Phenomenon
While Italy remains the epicenter of pasta culture, its influence has spread far and wide, permeating cuisines across the globe. From the hearty macaroni and cheese of North America to the spicy arrabbiata of Italy and the fragrant pad Thai of Thailand, pasta has been adapted and reinvented to suit diverse tastes and cultural preferences.
In each corner of the world, pasta takes on a unique identity, reflecting the ingredients, flavors, and traditions of its surroundings. Yet, despite these variations, pasta remains a universal symbol of comfort, nourishment, and celebration.
The Pleasures of Pasta
What makes pasta truly special is its ability to bring people together around the dinner table. Whether enjoyed as a comforting bowl of spaghetti bolognese on a chilly evening or a refreshing pasta salad on a hot summer day, pasta evokes feelings of warmth, joy, and togetherness.
Its versatility knows no bounds, as it pairs effortlessly with a myriad of sauces, proteins, vegetables, and spices. From the rich and indulgent to the light and refreshing, there's a pasta dish for every mood, occasion, and palate.
Conclusion: Embracing the Magic of Pasta
In conclusion, pasta is more than just a dish—it's"""


data : RouteParams -> BackendTask FatalError (Response Data ErrorPage)
data _ =
    Data pastaBlog
        |> Response.render
        |> BackendTask.succeed


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app sharedModel =
    { title = "Placeholder - Blog.Slug_"
    , body = [ Html.text "You're on the page Blog.Slug_" ]
    }
