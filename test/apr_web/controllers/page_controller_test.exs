defmodule AprWeb.PageControllerTest do
  use AprWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    assert text_response(conn, 401) =~ "Unauthorized"
  end
end
