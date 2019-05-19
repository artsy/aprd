defmodule AprWeb.PageControllerTest do
  use AprWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    assert response(conn, 302) =~ "redirected"
  end
end
