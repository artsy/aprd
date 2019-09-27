defmodule AprWeb.PingController do
  use AprWeb, :controller

  alias Apr.Commands

  def ping(conn, _) do
    json(conn, %{ping: "pong"})
  end
end
