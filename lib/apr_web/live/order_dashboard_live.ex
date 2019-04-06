defmodule AprWeb.OrderDashboardLive do
  use Phoenix.LiveView
  alias Apr.Events

  def render(assigns) do
    ~L"""
    <form phx-change="filter">
      <fieldset>
        Order <input type="checkbox" name="mode" value="order"/>
        Offer <input type="checkbox" name="mode" value="offer"/>
      </fieldset>
      <fieldset>
        Submitted <input type="checkbox" name="state" value="submitted" checked/>
        Approved <input type="checkbox" name="state" value="approved"/>
      </fieldset>
    </form>
    <%= for event <- @events do %>
      <div><%= event.topic %> -> <%= event.routing_key %></div>
    <% end %>
    """
  end

  def mount(_session, socket) do
    #if connected?(socket), do: :timer.send_interval(5000, self(), :tick)

    {:ok, get_events(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, get_events(socket)}
  end

  def handle_event("filter", %{"mode" => mode, "state" => state}, socket) do
    events = Events.list_events(topic: "commerce", routing_key: mode <> "." <> state)
    total_amounts = Enum.reduce(events,
      %{amount_cents: 0, commission_cents: 0},
      fn e, acc ->
        %{amount_cents: acc.amount_cents + e.payload.properties.buyer_total_cents, commission_cents: acc.commission_cents + e.payload.properties.commission_cents}
      end)
    {:noreply, assign(socket, events: events, total_amounts: total_amounts)}
  end

  defp get_events(socket) do
    assign(socket, events: Events.list_events)
  end
end