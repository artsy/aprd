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

  pipeline :auth do
    plug AprWeb.AuthPlug
  end

  scope "/auth", AprWeb do
    pipe_through :browser

    get "/", AuthController, :index
    get "/callback", AuthController, :callback
    get "/logout", AuthController, :delete
  end

  scope "/", AprWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :index
    get "/dashboard", PageController, :dashboard
  end
end
