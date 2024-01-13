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
        Help helpWith ->
            helpText = cmdHelp helpWith
            Stdout.line helpText

        CreateRocAppFile { platform, name, out } ->
            template =
                when platform is
                    BasicCli -> basicCliTemplate name
                    BasicWebserver -> basicWebserverTemplate name

            when out is
                Std ->
                    Stdout.line template

                File _ ->
                    Stdout.line "File output not implemented."
# ============================================
# Arguments
# ============================================

AppCommands : [
    Help HelpOptions,
    CreateRocAppFile
        {
            platform : AppPlatform,
            name : Str,
            out : [
                Std,
                File Path.Path,
            ],
        },
]

AppPlatform : [
    BasicCli,
    BasicWebserver,
]

HelpOptions : [
    ProgramHelp,
    CreateRocAppFileHelp,
]

parseArgs : List Str -> AppCommands
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
                        CreateRocAppFile {
                            platform,
                            name,
                            out: File (Path.fromStr path),
                        }

                    _ -> Help ProgramHelp

            ["-o"] ->
                Help ProgramHelp

            [name] ->
                CreateRocAppFile { platform, name, out: Std }

            _ ->
                Help ProgramHelp

    when args is
        [] | [""] | ["help"] | ["-h"] | ["--help"] ->
            Help ProgramHelp

        ["cli"] | ["basic-cli"] | ["roc-lang/basic-cli"] ->
            parseCreateAppParams BasicCli ["main"]

        ["cli", .. as tail] | ["basic-cli", .. as tail] | ["roc-lang/basic-cli", .. as tail] ->
            parseCreateAppParams BasicCli tail

        ["webserver"] | ["basic-webserver"] | ["roc-lang/basic-webserver"] ->
            parseCreateAppParams BasicWebserver ["main"]

        ["webserver", .. as tail] | ["basic-webserver", .. as tail] | ["roc-lang/basic-webserver", .. as tail] ->
            parseCreateAppParams BasicWebserver tail

        # ["app"] ->
        #     Help CreateRocAppFileHelp
        _ ->
            Help ProgramHelp

cmdHelp : HelpOptions -> Str
cmdHelp = \helpWith ->
    when helpWith is
        ProgramHelp ->
            """
            Hi, let me help you create new .roc files. I'll even inject the chosen platform for you.

            Example:
            As of now, I print the new file to stdout, so it's up to you to pipe it in the right destination. 

                rng cli foo |> foo.roc


            Command:
                
                rng [platform] [name]       Creates a new Roc App, with the chosen platform. 
                                            [name] is optional btw. If you leave it empty, I chose \"main\" as the apps name.


            Supported Platforms:
                        
                roc-lang/basic-cli          v0.7.1  Aliases: cli, basic-cli
                roc-lang/basic-webserver    v0.1    Aliases: webserver, basic-webserver


            Happy Building and Roc'n go!
            """

        CreateRocAppFileHelp ->
            """
            """

# ============================================
# roc app file
# ============================================

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

basicWebserverTemplate : Str -> Str
basicWebserverTemplate = \appName -> 
    pf = Dict.get testPlatformsPath "basic-webserver" |> Result.withDefault "Ooops"

    """
    app \"\(appName)\"
        packages { pf: 
            \"\(pf)\" 
        }
        imports [
            pf.Stdout,
            pf.Task.{ Task },
            pf.Http.{ Request, Response },
            pf.Utc,
        ]
        provides [main] to pf

    main : Request -> Task Response []
    main = \\req ->

        # Log request date, method and url
        date <- Utc.now |> Task.map Utc.toIso8601Str |> Task.await
        {} <- Stdout.line \"\\(date) \\(Http.methodToStr req.method) \\(req.url)\" |> Task.await

        # Respond with request body
        when req.body is
            EmptyBody -> Task.ok { status: 200, headers: [], body: [] }
            Body internal -> Task.ok { status: 200, headers: [], body: internal.body }
    """


