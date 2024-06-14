module Route.Foo.Bar_.Baz__ exposing (Model, Msg, RouteParams, route, Data, ActionData)

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
    { bar : String, baz : Maybe String }


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
    { content : String }


type alias ActionData =
    BackendTask.BackendTask FatalError.FatalError (List RouteParams)


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


data : RouteParams -> BackendTask.BackendTask error Data
data _ =
    Data pastaBlog
        |> BackendTask.succeed


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "Foo.Bar_.Baz__"
    , body =
        [ Html.h2 []
            [ Html.p []
                [ Html.text app.data.content
                ]
            ]
        ]
    }


pages : BackendTask.BackendTask FatalError.FatalError (List RouteParams)
pages =
    BackendTask.succeed
        [ { bar = "without-baz", baz = Nothing }
        , { bar = "with-baz", baz = Just "bazzer" }
        ]
