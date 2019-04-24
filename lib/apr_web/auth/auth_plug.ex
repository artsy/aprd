defmodule AprWeb.AuthPlug do
  import Plug.Conn
  alias AprWeb.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _params) do
    with access_token when not is_nil(access_token) <- Plug.Conn.get_session(conn, :access_token),
         {:ok, %{"roles" => roles}} <- Apr.JwtToken.verify_and_validate(access_token) do
      sales_admin =
        roles
        |> String.split(",")
        |> Enum.member?("sales_admin")

      if sales_admin do
        conn
      else
        # cannot access
        conn
        |> send_resp(403, "")
        |> halt()
      end
    else
      _ ->
        # not logged in, redirect to login
        conn
        |> Phoenix.Controller.redirect(to: Routes.auth_path(conn, :index))
        |> halt()
    end
  end
end
