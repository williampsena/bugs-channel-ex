# BugsChannel

![workflow](https://github.com/williampsena/bugs-channel/actions/workflows/main.yml/badge.svg)

This repository contains information about handling issues with proxy. 
I decided to begin this project with the goal of making error handling as simple as possible.
I use [Sentry](https://sentry.io) and [Honeybadger](https://www.honeybadger.io), and both tools are fantastic for quickly tracking down issues. However, the purpose of this project is not to replace them, but rather to provide a simple solution for you to run on premise that is easy and has significant features.

> I believe the project will be ready for production within the next three months. 🙏🏾

# Running project

The command below starts a web application that listens on port 4000 by default.

```shell
mix api
# or
mix run --no-halt
```

# Tests

```shell
mix test
# or
mix coveralls
```

# Code Analysis

Credo is in charge of maintaining code that follows certain patterns.

```shell
mix credo -a
```
