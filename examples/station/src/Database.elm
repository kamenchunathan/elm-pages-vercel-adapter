module Database exposing (..)

import Json.Decode as Decode

type alias NewsStory =
    { title : String
    , slug : String
    , summary : String
    , body : String
    , author : String
    , publishedDate : String
    }

newsStoryDecoder : Decode.Decoder NewsStory
newsStoryDecoder =
    Decode.map6 NewsStory
        (Decode.field "title" Decode.string)
        (Decode.field "slug" Decode.string)
        (Decode.field "summary" Decode.string)
        (Decode.field "body" Decode.string)
        (Decode.field "author" Decode.string)
        (Decode.field "publishedDate" Decode.string)

allNews : List NewsStory
allNews =
    [ { title = "Elm Gains Popularity in Web Development"
      , slug = "elm-gains-popularity"
      , summary = "The Elm programming language is seeing a surge in adoption, with many developers praising its reliability and ease of use."
      , body = "A detailed report on the rise of Elm in the web development community. The report covers the history of Elm, its core concepts, and why it's becoming a popular choice for building web applications. It includes interviews with developers who have switched to Elm from other languages, and a look at some of the most popular Elm projects."
      , author = "Jane Doe"
      , publishedDate = "2025-07-24"
      }
    , { title = "Vercel Adapter for elm-pages Released"
      , slug = "vercel-adapter-released"
      , summary = "A new adapter allows for easy deployment of elm-pages sites to Vercel, a popular platform for hosting web applications."
      , body = "Learn how to deploy your elm-pages project to Vercel with this new adapter. This article provides a step-by-step guide to configuring your project and deploying it to Vercel. It also covers some of the benefits of using Vercel for hosting your elm-pages site, such as automatic deployments and serverless functions."
      , author = "John Smith"
      , publishedDate = "2025-07-23"
      }
    , { title = "TailwindCSS Integration with Elm-Pages"
      , slug = "tailwindcss-integration"
      , summary = "A guide to using TailwindCSS with your elm-pages application, a popular utility-first CSS framework."
      , body = "This tutorial will walk you through the steps to get TailwindCSS working in your project. It covers how to install and configure TailwindCSS, and how to use it to style your elm-pages application. It also includes some tips and tricks for using TailwindCSS effectively with Elm."
      , author = "Jane Doe"
      , publishedDate = "2025-07-22"
      }
    ]

topNews : List NewsStory
topNews =
    List.take 2 allNews

getNewsBySlug : String -> Maybe NewsStory
getNewsBySlug slug =
    List.head (List.filter (\story -> story.slug == slug) allNews)

getNewsSlugs : List String
getNewsSlugs =
    List.map .slug allNews
