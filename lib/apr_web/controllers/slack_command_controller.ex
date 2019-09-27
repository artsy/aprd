defmodule AprWeb.SlackCommandController do
  use AprWeb, :controller

  alias Apr.Commands

  def command(conn, params = %{token: token}) do
    # check that token matches, that the POST comes from our slack integration
    if System.get_env("SLACK_SLASH_COMMAND_TOKEN") != token do
      conn
      |> send_resp(403, "Access Denied")
      |> halt()
    else
      json(conn, Commands.process_command(params))
    end
  end
end
