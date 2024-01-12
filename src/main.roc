app "roc-n-go"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.1/Icc3xJoIixF3hCcfXrDwLCu4wQHtNdPyoJkEbkgIElA.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Stderr,
        pf.Task.{ Task },
        pf.File,
        pf.Path,
    ]
    provides [main] to pf

main : Task {} I32
main =

    f = basicCli "my-stuff"
    result <- File.writeBytes (Path.fromStr "test-out/\(f.name)") f.body |> Task.attempt

    when result is
        Err _ ->
            {} <- Stderr.line "Well that didn't work" |> Task.await
            Task.ok {}

        Ok {} ->
            {} <- Stdout.line "SUCCESS!!! -> Well it did work" |> Task.await
            Task.ok {}

basicCli : Str -> { name : Str, body : List U8 }
basicCli = \name -> {
    name: "\(name).roc",
    body: Str.toUtf8
        """
        app \"\(name)\"
            packages {
                pf: \"https://github.com/roc-lang/basic-cli/releases/download/0.7.1/Icc3xJoIixF3hCcfXrDwLCu4wQHtNdPyoJkEbkgIElA.tar.br\",
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
        """,
}
