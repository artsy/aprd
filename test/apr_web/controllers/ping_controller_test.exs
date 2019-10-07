defmodule AprWeb.PingControllerTest do
  use AprWeb.ConnCase

  test "GET /ping", %{conn: conn} do
    conn = get(conn, "/api/ping")

    assert json_response(conn, 200) == %{"ping" => "pong"}
  end
end
