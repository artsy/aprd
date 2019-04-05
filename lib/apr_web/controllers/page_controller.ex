defmodule AprWeb.PageController do
  use AprWeb, :controller
  alias Phoenix.LiveView

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def dashboard(conn, _) do
    LiveView.Controller.live_render(conn, AprWeb.OrderDashboardLive, session: %{})
  end
end
