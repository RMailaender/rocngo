app "roc-n-go"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.1/Icc3xJoIixF3hCcfXrDwLCu4wQHtNdPyoJkEbkgIElA.tar.br",
    }
    imports [
        # pf.Stdout,
        # pf.Stderr,
        pf.Task.{ Task },
        # pf.File,
        # pf.Path,
        pf.Arg,
    ]
    provides [main] to pf

main : Task {} I32
main =
    args <- Arg.list |> Task.await

    dbg args

    Task.ok {}

## -- Help
##
## > rng                        -> Help
## > rng -h                     -> Help
## > rng --help                 -> Help

## -- Help for a specific sub-cmd
## > rng [cmd]                  -> Help
## > rng -h [cmd]               -> Help
## > rng --help [cmd]           -> Help [CMD]

## -- CreateRocAppFile Sub Cmd
##
##
## - CreateRocAppFile is the default Command, so it can be invoked directly
##
## > rng main                   -> CreateRocAppFile BasicCli "main"
## > rng basic-cli main         -> CreateRocAppFile BasicCli "main"
## > rng basic-webserver main   -> CreateRocAppFile BasicWebserver "main"
##
parseArgs : List Str -> _
parseArgs = \args ->
    parsePlatform = \str ->
        when str is
            "cli"
            | "basic-cli" ->
                Ok BasicCli

            "webserver"
            | "basic-webserver" ->
                Ok BasicWebserver

            _ ->
                Err UnsupportedPlatform

    parseCreateAppFileCmd : List Str -> Result _ _
    parseCreateAppFileCmd = \cmdArgs ->
        when cmdArgs is
            ["app-file"] ->
                Ok (CreateRocAppFile BasicCli)

            ["app-file", maybePlatform] ->
                when parsePlatform maybePlatform is
                    Ok platform ->
                        Ok (CreateRocAppFile platform)

                    Err _ ->
                        Ok (CreateRocAppFile HelpUnsupportedPlatform)

            [maybePlatform] ->
                when parsePlatform maybePlatform is
                    Ok platform ->
                        Ok (CreateRocAppFile platform)

                    Err _ ->
                        Err cmdArgs

            _ ->
                Err args

    parseInitProjectCmd : List Str -> Result _ _
    parseInitProjectCmd = \cmdArgs ->
        when cmdArgs is
            ["init"] ->
                Ok (InitProject BasicCli)

            ["init", maybePlatform] ->
                when parsePlatform maybePlatform is
                    Ok platform ->
                        Ok (InitProject platform)

                    Err _ ->
                        Ok (InitProject HelpUnsupportedPlatform)

            _ ->
                Err cmdArgs

    parseHelpCmd : List Str -> Result _ _
    parseHelpCmd = \cmdArgs ->
        when cmdArgs is
            [] | [""] | ["help"] | ["-h"] | ["--help"] ->
                Ok (Help Program)

            _ ->
                Err cmdArgs

    args
    |> parseCreateAppFileCmd
    |> Result.onErr parseInitProjectCmd
    |> Result.onErr parseHelpCmd
    |> Result.withDefault (Help Program)

# when args is
#     [] | [""] ->
#         Ok (CreateRocAppFile BasicCli)

#     ["init"] ->
#         Ok (InitProject BasicCli)

#     ["init", maybePlatform] ->
#         when parsePlatform maybePlatform is
#             Ok platform -> Ok (InitProject platform)
#             Err _ ->
#                 Err UnsupportedPlatform

#     [maybePlatform] ->
#         when parsePlatform maybePlatform is
#             Ok platform -> Ok (CreateRocAppFile platform)
#             Err _ -> Err InvalidArgs

#     _ ->
#         Err InvalidArgs

Platforms : [
    BasicWebserver,
    BasicCli,
]

# InitProject [Platform]
expect
    result =
        [
            (["init"], InitProject BasicCli),
            (["init", "basic-cli"], InitProject BasicCli),
            (["init", "basic-webserver"], InitProject BasicWebserver),
            (["init", "foo-bar"], InitProject HelpUnsupportedPlatform),
        ]
        |> List.map \(args, expected) -> (parseArgs args, expected)

    List.all result \(actual, expected) -> actual == expected

# help
expect
    result =
        [
            ([], Help Program),
            ([""], Help Program),
            (["foo-bar"], Help Program),
        ]
        |> List.map \(args, expected) -> (parseArgs args, expected)

    List.all result \(actual, expected) -> actual == expected

# CreateRocAppFile
expect
    result =
        [
            (["basic-cli"], CreateRocAppFile BasicCli),
            (["basic-webserver"], CreateRocAppFile BasicWebserver),
            (["app-file"], CreateRocAppFile BasicCli),
            (["app-file", "basic-cli"], CreateRocAppFile BasicCli),
            (["app-file", "basic-webserver"], CreateRocAppFile BasicWebserver),
            (["app-file", "foo-bar"], CreateRocAppFile HelpUnsupportedPlatform),
        ]
        |> List.map \(args, expected) -> (parseArgs args, expected)

    List.all result \(actual, expected) -> actual == expected

testPlatformsPath : Dict Str Str
testPlatformsPath =
    [
        ("basic-cli", "https://github.com/roc-lang/basic-cli/releases/download/0.7.1/Icc3xJoIixF3hCcfXrDwLCu4wQHtNdPyoJkEbkgIElA.tar.br"),
        ("basic-webserver", "https://github.com/roc-lang/basic-webserver/releases/download/0.1/dCL3KsovvV-8A5D_W_0X_abynkcRcoAngsgF0xtvQsk.tar.br"),
    ]
    |> Dict.fromList

Platform : {
    key : Str,
    paths : List Str,
    template : Str,
}

# f = basicCli "my-stuff"
# result <- File.writeBytes (Path.fromStr "test-out/\(f.name)") f.body |> Task.attempt

# when result is
#     Err _ ->
#         {} <- Stderr.line "Well that didn't work" |> Task.await
#         Task.ok {}

#     Ok {} ->
#         {} <- Stdout.line "SUCCESS!!! -> Well it did work" |> Task.await
#         Task.ok {}

# basicCli : Str -> { name : Str, body : List U8 }
# basicCli = \name -> {
#     name: "\(name).roc",
#     body: Str.toUtf8
#         """
#         app \"\(name)\"
#             packages {
#                 pf: \"https://github.com/roc-lang/basic-cli/releases/download/0.7.1/Icc3xJoIixF3hCcfXrDwLCu4wQHtNdPyoJkEbkgIElA.tar.br\",
#             }
#             imports [
#                 pf.Stdout,
#                 pf.Task.{ Task },
#             ]
#             provides [main] to pf

#         main : Task {} I32
#         main =
#             {} <- Stdout.line \"there is nothing to see here yet.\" |> Task.await

#             Task.ok {}
#         """,
# }
