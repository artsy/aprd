<img src="/assets/static/images/APR.png" width="100px" />

# APRd (Artsy Real-time Dashboard) [![CircleCI](https://circleci.com/gh/artsy/aprd.svg?style=svg)](https://circleci.com/gh/artsy/aprd)

APRd (aka. APR dashboard), is a real-time dashboard built in [Elixir](https://elixir-lang.org/) on [Phoenix Framework](https://phoenixframework.org/). For it's real-time dashboard it's using [Phoenix Live View](https://github.com/phoenixframework/phoenix_live_view) to be able to provide websocket based pages that can update in real-time based on updates on the server side.

## Meta

- State: production
- Production: https://aprd.artsy.net
- Staging: https://aprd-staging.artsy.net
- GitHub: https://github.com/artsy/aprd/
- CI: [CircleCI](https://circleci.com/gh/artsy/apr-dashboard); merged PRs to artsy/apr-dashboard#main are automatically deployed to staging. PRs from `staging` to `release` are automatically deployed to production. [Start a deploy...](https://github.com/artsy/apr-dashboard/compare/release...staging?expand=1)
- Point People: [@jpotts244](https://github.com/jpotts244)

## Clone the project

```
$ git clone git@github.com:artsy/aprd.git
```

## Setup using setup script

- Read and run setup script.
  ```
  $ cat bin/setup
  $ bin/setup
  ```

## Setup manually (not using setup script)

- Install [Elixir](https://elixir-lang.org/install.html)

  Using Homebrew

  ```
  $ brew update
  $ brew install elixir
  ```

  - Ensure that everything installed correctly by running `mix`, you should not see the following error
    ```
    $ command not found: mix
    ```

- Ensure you have [postgres](https://www.postgresql.org/download/) and [rabbitmq](https://www.rabbitmq.com/download.html) installed
  - Once installed make sure both are running on your local machine (using Homebrew)
    ```
    $ brew services start postgresql
    $ brew services start rabbitmq
    ```
- Install dependencies with `mix deps.get`
- In your command line run
  ```
  brew install autoconf@2.69 && \
  brew link --overwrite autoconf@2.69 && \
  autoconf -V
  ```
  to fix an issue in erlang 23
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `cd assets && npm install`
- `s3://artsy-citadel/aprd/.env.shared` contains common configuration values for local dev. Create a `.env.shared` file locally and copy using this command:

```
aws s3 cp s3://artsy-citadel/aprd/.env.shared ./
```

- `.env` should contain configuration values specific to your local development. Create the file if it does not exist. See `.env.example` for suggestion on values you might want to customize.
- We use [Phoenix Live View](https://github.com/phoenixframework/phoenix_live_view) for our real-time data presentation. Make sure `SECRET_SALT` exists in `.env.shared` or `.env`. You can generate a secret salt with:
  - `mix phx.gen.secret 32`
- The app defaults to using local RabbitMQ. If you want to use the one in our Staging environment, set the appropriate values in `.env`
- Start Phoenix endpoint with a wrapper script: `bin/start.sh`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Running the test suite

Run the entire test suite using the following command

```
$ mix test
```

To run a specific test file, add the path to the test file

```
$ mix test test/apr/views/commerce/commerce_transaction_slack_view_test.exs
```

## Architecture

APRd listens on RabbitMQ for different topics. Once it receives a new event, it will store a copy of that event locally in it's database so we can later process the data and provide detailed and aggregated data.

Whenever we receive a new event, after storing the event locally, we use Phoenix's local PUB/SUB to broadcast we received an event. And then our websocket live views are listening on this internal PUB/SUB and they update the data on listening Webosckets reflecting the latest event updated.

## Artsy Slack Setup

### Setting up a new topic or channel

Before a new topic can be subscribed to from Slack, the topic must exist in APR's database. E.g.:

```bash
$ hokusai staging run --tty 'iex -S mix'
Apr.Subscriptions.create_topic(%{name: "auction_results"})
```

To add the APR integration to a _new_ channel:

1. In the channel's settings, choose _Integrations_,
1. then _Add apps_, then
1. search for and select _APR Announcer_

In the channel, confirm the available topics and subscribe:

```
/apr help
/apr topics
/apr subscribe auction_results
```

### Recovering from a Slack connection disruption

APRd is used to power critical alerting workflows in Artsy's Slack organization. After a recent incident where APRd lost its connection to Artsy's Slack, we surfaced the following steps to re-connect the digital assets needed to get it all working:

1. Re-enable the `/apr` slash command: https://artsy.slack.com/services/B227A48KX
1. Re-enable the `@apr / APR Announcer` Slack bot: https://artsy.slack.com/services/B04JQLTBUAU
1. Re-invite the Bot in (2) to the [appropriate Slack channels](https://www.notion.so/artsy/Resolving-APRd-downtime-2e1bb0e59d9e46cc8d1fe58ff04df088#7d87b3f3be804ab9802310c0603da45e)
   - You can check your work by reading the Channels attribute on the Bot show page: https://artsy.slack.com/services/B04JQLTBUAU
1. Re-generate the bot API token (via https://artsy.slack.com/services/B04JQLTBUAU)
1. Run `hokusai [staging|production] env set SLACK_API_TOKEN=token-from-step-4`
1. Run `hokusai [staging|production] refresh`
1. If it was down for more than a few minutes, we likely need to fetch the events that were missed. See the playbook in [Notion](https://www.notion.so/artsy/Resolving-APRd-downtime-2e1bb0e59d9e46cc8d1fe58ff04df088) for details on how to do so.
