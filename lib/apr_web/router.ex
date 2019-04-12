defmodule AprWeb.Router do
  use AprWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BasicAuth, use_config: {:apr, :authentication}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AprWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/dashboard", PageController, :dashboard
  end

  # Other scopes may use custom stacks.
  # scope "/api", AprWeb do
  #   pipe_through :api
  # end
end
