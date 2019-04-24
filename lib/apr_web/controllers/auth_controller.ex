defmodule AprWeb.AuthController do
  use AprWeb, :controller

  @doc """
  This action is reached via `/auth/:provider` and redirects to the OAuth2 provider
  based on the chosen strategy.
  """
  def index(conn, _params) do
    redirect(conn, external: ArtsyOauth.authorize_url!())
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  @doc """
  This action is reached via `/auth/:provider/callback` is the the callback URL that
  the OAuth2 provider will redirect the user back to with a `code` that will
  be used to request an access token. The access token will then be used to
  access protected resources on behalf of the user.
  """
  def callback(conn, %{"code" => code}) do
    # Exchange an auth code for an access token
    client = ArtsyOauth.get_token!(code: code)

    # Request the user's data with the access token
    # user = get_user!("artsy", client)

    # Store the user in the session under `:current_user` and redirect to /.
    # In most cases, we'd probably just store the user's ID that can be used
    # to fetch from the database. In this case, since this example app has no
    # database, I'm just storing the user map.
    #
    # If you need to make additional resource requests, you may want to store
    # the access token as well.
    {:ok, %{"access_token" => access_token}} = Jason.decode(client.token.access_token)
    conn
    |> put_session(:access_token, access_token)
    |> redirect(to: "/dashboard")
  end
end
