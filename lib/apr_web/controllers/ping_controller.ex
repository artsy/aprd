defmodule AprWeb.PingController do
  use AprWeb, :controller

  def ping(conn, _) do
    json(conn, %{ping: "pong"})
  end
end
