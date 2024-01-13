# Roc'n go

So the idea is: you choose a platform, give it app a name and voila. Everything is setup for you to begin coding.

```shell
rng cli foo |> foo.roc
```

## Installation

Since you're interested in this app, I suppose you already have the Roc compiler installed, right? :-)

So as of now, the easiest way might be to just clone this repo and build it locally.

```shell
./build.sh
```

## Future plans

As of now, the app is pretty limited in it's capabilities. Here some ideas for how I want to improve it:

- Add more platforms of course
- Offer different platform version
- Read the platform from a json, instead of hardcoded into the app
- Allow more kinds of Roc files to be created
    - interface
    - package
    - platform
- Allow the user to give a list of packages to be injected into the created file. (E.g Hasnep/roc-html, lukewilliamboswell/roc-json etc.)
- Allow for a complete project scaffolding
- Create a Roc'n go platform which could be used to easily create a custom rng binary. That way one could extend the app with custom templates.
- Allow for local platforms
