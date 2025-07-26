module GlobPatterns exposing (blogPostsGlob, journalPostsGlob)

import BackendTask exposing (BackendTask)
import BackendTask.Glob as Glob
import FatalError exposing (FatalError)


blogPostsGlob : BackendTask FatalError (List { filePath : String, slug : String })
blogPostsGlob =
    Glob.succeed (\filePath slug -> { filePath = filePath, slug = slug })
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/blog/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toBackendTask


journalPostsGlob : BackendTask FatalError (List { filePath : String, slug : String })
journalPostsGlob =
    Glob.succeed (\filePath slug -> { filePath = filePath, slug = slug })
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/journal/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toBackendTask
