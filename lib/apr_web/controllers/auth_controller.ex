defmodule AprWeb.AuthController do
  use AprWeb, :controller

  @doc """
  This action is reached via `/auth` and redirects to the OAuth2 provider
  based on the chosen strategy.
  """
  def index(conn, _params) do
    redirect(conn, external: Artsy.Auth.OauthStrategy.authorize_url!())
  end

  def signout(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(external: Artsy.Auth.OauthStrategy.signout_url())
  end

  @doc """
  This action is reached via `/auth/callback` is the the callback URL that
  the OAuth2 provider will redirect the user back to with a `code` that will
  be used to request an access token. The access token will then be used to
  access protected resources on behalf of the user.
  """
  def callback(conn, %{"code" => code}) do
    # Exchange an auth code for an access token
    client = Artsy.Auth.OauthStrategy.get_token!(code: code)

    conn
    |> put_session(:access_token, client.token.access_token)
    |> redirect(to: "/")
  end
end
