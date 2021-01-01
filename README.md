<img src="/assets/static/images/APR.png" width="100px" />

# APRd (Artsy Real-time Dashboard) [![CircleCI][ci_badge]][circleci]

APRd (aka. APR dashboard), is a real-time dashboard built in [Elixir][elixir] on [Phoenix Framework][phoenixframework].
For it's real-time dashboard it's using [Phoenix Live View][phoenix_live_view] to be able to provide websocket based
pages that can update in real-time based on updates on the server side.

APRd also powers the Slack notification workflows at Artsy. It consumes RabbitMQ events, composes Slack messages, and
notifies subscribing Slack channels. Users can subscribe to topics from a Slack channel with the `/apr` Slack slash
command that APRd provides.

## Meta

- State: production
- Production: https://aprd.artsy.net
- Staging: https://aprd-staging.artsy.net
- GitHub: https://github.com/artsy/aprd/
- CI: [CircleCI][circleci]; merged PRs to artsy/aprd#master are automatically deployed to staging. PRs from `staging` to
  `release` are automatically deployed to production. [Start a deploy...][deploy]
- Point People: [@jpotts244][jpotts244], [@zephraph][zephraph]

## Setup

- Clone the project
- Install [Elixir][elixir_install]

  Using Homebrew
  ```
  brew update
  brew install elixir
  ```
- Ensure you have [postgres][postgresql] and [rabbitmq][rabbitmq] installed
  - Once installed make sure both are running on your local machine (using Homebrew)
    ```
    brew services start postgresql
    brew services start rabbitmq
    ```
- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `cd assets && npm install`
- Copy `.env.example` to `.env` and populate environment variables
- We use [Phoenix Live View][phoenix_live_view] for our real-time data presentation. Make sure to set `SECRET_SALT` in
  your `.env`. Generate a secret salt with:
  - `mix phx.gen.secret 32`
- Start Phoenix endpoint with `foreman run mix phx.server`

Now you can visit [`localhost:4000`][localhost] from your browser.

## Running the test suite

Run the entire test suite using the following command
```
mix test
```

To run a specific test file, add the path to the test file
```
mix test test/apr/views/commerce/commerce_transaction_slack_view_test.exs
```

## Architecture

APRd listens on RabbitMQ for different topics. Once it receives a new event, it will store a copy of that event locally
in it's database so we can later process the data and provide detailed and aggregated data.

Whenever we receive a new event, after storing the event locally, we use Phoenix's local PUB/SUB to broadcast we
received an event. And then our websocket live views are listening on this internal PUB/SUB and they update the data on
listening Webosckets reflecting the latest event updated.

## Artsy Slack Setup

APRd is used to power critical alerting workflows in Artsy's Slack organization. After a recent incident where APRd lost
its connection to Artsy's Slack, we surfaced the following steps to re-connect the digital assets needed to get it all
working:

1. Re-enable the `/apr` slash command: https://artsy.slack.com/services/B227A48KX
1. Re-enable the `@apr / APR Announcer` Slack bot: https://artsy.slack.com/services/70260076245
1. Re-invite the Bot in (2) to the appropriate Slack channels
    - You can check your work by reading the Channels attribute on the Bot show page:
      https://artsy.slack.com/services/70260076245
1. Re-generate the bot API token (via https://artsy.slack.com/services/70260076245)
1. Run `hokusai [staging|production] env set SLACK_API_TOKEN=token-from-step-4`
1. Run `hokusai [staging|production] refresh`

[ci_badge]: https://circleci.com/gh/artsy/aprd.svg?style=svg
[circleci]: https://circleci.com/gh/artsy/aprd
[elixir]: https://elixir-lang.org/
[elixir_install]: https://elixir-lang.org/install.html
[phoenix_live_view]: https://github.com/phoenixframework/phoenix_live_view
[deploy]: https://github.com/artsy/apr-dashboard/compare/release...staging?expand=1
[jpotts244]: https://github.com/jpotts244
[zephraph]: https://github.com/zephraph
[localhost]: http://localhost:4000
[phoenixframework]: https://phoenixframework.org/
[postgresql]: https://www.postgresql.org/download/
[rabbitmq]: https://www.rabbitmq.com/download.html
