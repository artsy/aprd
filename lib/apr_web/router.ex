defmodule AprWeb.Router do
  use AprWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authenticated do
    plug Artsy.Auth.Plug
  end

  scope "/auth", AprWeb do
    pipe_through :browser

    get "/", AuthController, :index
    get "/callback", AuthController, :callback
    get "/signout", AuthController, :delete
  end

  scope "/api", AprWeb do
    get "/ping", PingController, :ping
    post "/slack", SlackCommandController, :command
  end

  scope "/", AprWeb do
    pipe_through [:browser, :authenticated]

    get "/", PageController, :dashboard
    get "/dashboard", PageController, :dashboard
    live "/partner_selection", OrderByPartner, session: [:access_token]
  end
end
