defmodule AprWeb.OrderDashboardLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <form phx-change="filter">
      <fieldset>
        Order <input type="checkbox" name="mode" value="order"/>
        Offer <input type="checkbox" name="mode" value="offer"/>
      </fieldset>
    </form>
    <%= for event <- @events do %>
      <div><%= event.topic %> -> <%= event.routing_key %></div>
    <% end %>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(5000, self(), :tick)

    {:ok, get_events(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, get_events(socket)}
  end

  defp get_events(socket) do
    assign(socket, events: Apr.Events.list_events)
  end
end