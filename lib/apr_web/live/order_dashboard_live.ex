defmodule AprWeb.OrderDashboardLive do
  use Phoenix.LiveView
  alias Apr.Events

  def render(assigns) do
    ~L"""
    <button phx-click="today">Today</button>
    <button phx-click="last_week">Last 7 Days</button>
    <button phx-click="last_month">Last Month</button>
    <div>
      Totals: <%= @totals.amount_cents %>
      Commission Totals: <%= @totals.commission_cents %>
    </div>
    <%= for event <- @events do %>
      <div><%= event.topic %> -> <%= event.routing_key %></div>
    <% end %>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: AprWeb.Endpoint.subscribe("events")

    {:ok, get_events(socket)}
  end

  def handle_event("today", _, socket) do
    {:noreply, get_events(socket, 1)}
  end

  def handle_event("last_week", _, socket) do
    {:noreply, get_events(socket, 7)}
  end

  def handle_event("last_month", _, socket) do
    {:noreply, get_events(socket, 30)}
  end

  def handle_info(%{event: "new_event", payload: _event}, socket) do
    {:noreply, get_events(socket)}
  end

  defp get_events(socket, day_threshold \\ 1) do
    events = Events.list_events(routing_key: "order.approved", day_threshold: day_threshold)
    assign(socket, events: events, totals: get_totals(events))
  end

  defp get_totals(events) do
    events
    |> Enum.reduce(
        %{amount_cents: 0, commission_cents: 0},
        fn e, acc ->
          %{
            amount_cents: acc.amount_cents + e.payload["properties"]["buyer_total_cents"],
            commission_cents: acc.commission_cents + e.payload["properties"]["commission_fee_cents"]
          }
        end
      )
  end
end
