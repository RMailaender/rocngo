app "roc-n-go"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.1/Icc3xJoIixF3hCcfXrDwLCu4wQHtNdPyoJkEbkgIElA.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Task.{ Task },
        pf.Path,
        pf.Arg,
    ]
    provides [main] to pf

main : Task {} I32
main =
    args <- Arg.list |> Task.await

    when parseArgs (List.dropFirst args 1) is
        Help ->
            Stdout.line "Help!"

        Invalid ->
            Stdout.line "invalid"

        CreateAppFile { platform, name, out } ->
            template =
                when platform is
                    BasicCli -> basicCliTemplate name
                    BasicWebserver -> "Not Implemented"

            when out is
                Std ->
                    Stdout.line template

                File _ ->
                    Stdout.line "File output not implemented."

Platform : [
    BasicCli,
    BasicWebserver,
]
parseArgs : List Str
    -> [
        Help,
        Invalid,
        CreateAppFile
            {
                platform : Platform,
                name : Str,
                out : [
                    Std,
                    File Path.Path,
                ],
            },
    ]
parseArgs = \args ->
    parseCreateAppParams = \platform, params ->
        when params is
            ["-o", path] | ["--output", path] ->
                file =
                    path
                    |> Str.split "/"
                    |> List.last
                    |> Result.map \s -> s |> Str.split "."
                    |> Result.withDefault []

                when file is
                    [name, "roc"] ->
                        CreateAppFile {
                            platform,
                            name,
                            out: File (Path.fromStr path),
                        }

                    _ -> Invalid

            ["-o"] ->
                Invalid

            [name] ->
                CreateAppFile { platform, name, out: Std }

            _ ->
                Invalid

    when args is
        [] | [""] ->
            Help

        ["cli"] | ["basic-cli"] ->
            parseCreateAppParams BasicCli ["main"]

        ["cli", .. as tail] | ["basic-cli", .. as tail] ->
            parseCreateAppParams BasicCli tail

        ["webserver"] | ["basic-webserver"] ->
            parseCreateAppParams BasicWebserver ["main"]

        ["webserver", .. as tail] | ["basic-webserver", .. as tail] ->
            parseCreateAppParams BasicWebserver tail

        ["app"] ->
            Help

        _ ->
            Invalid

testPlatformsPath : Dict Str Str
testPlatformsPath =
    [
        ("basic-cli", "https://github.com/roc-lang/basic-cli/releases/download/0.7.1/Icc3xJoIixF3hCcfXrDwLCu4wQHtNdPyoJkEbkgIElA.tar.br"),
        ("basic-webserver", "https://github.com/roc-lang/basic-webserver/releases/download/0.1/dCL3KsovvV-8A5D_W_0X_abynkcRcoAngsgF0xtvQsk.tar.br"),
    ]
    |> Dict.fromList

basicCliTemplate : Str -> Str
basicCliTemplate = \name ->
    pf = Dict.get testPlatformsPath "basic-cli" |> Result.withDefault "oops"

    """
    app \"\(name)\"
        packages {
            pf: \"\(pf)\",
        }
        imports [
            pf.Stdout,
            pf.Task.{ Task },
        ]
        provides [main] to pf

    main : Task {} I32
    main =
        {} <- Stdout.line \"there is nothing to see here yet.\" |> Task.await

        Task.ok {}
    """

