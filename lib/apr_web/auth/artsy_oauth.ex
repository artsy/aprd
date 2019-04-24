defmodule ArtsyOauth do
  @moduledoc """
  An OAuth2 strategy for Artsy.
  """
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  # Public API

  def client do
    Application.get_env(:apr, ArtsyOAuth)
    |> OAuth2.Client.new()
  end

  def authorize_url! do
    OAuth2.Client.authorize_url!(client(), scope: "offline_access")
  end

  def get_token!(params \\ [], headers \\ []) do
    OAuth2.Client.get_token!(
      client(),
      Keyword.merge(params,
        client_secret: client().client_secret,
        scope: "offline_access",
        grant_type: "authorization_code"
      )
    )
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end
