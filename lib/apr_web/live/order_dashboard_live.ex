defmodule AprWeb.OrderDashboardLive do
  use Phoenix.LiveView
  import Apr.ViewHelper
  alias Apr.Events

  def render(assigns) do
    ~L"""
    <div class="main-live">
      <section class="main-stats">
        <div class="flex flex-direction-column text-align-center">
          <div class="sans-8"> <%= Money.to_string(Money.new(@totals.amount_cents, :USD)) %> </div>
          <span class="sans-3">GMV</span>
        </div>
        <div class="flex flex-direction-column text-align-center">
          <div class="sans-8"> <%= Money.to_string(Money.new(@totals.commission_cents, :USD)) %> </div>
          <span class="sans-3">Comission</span>
        </div>
      </section>
      <div class="event-section">
        <%= for event <- @events do %>
          <div class="artwork-event">
            <% artwork = List.first(@artworks[event.payload["object"]["id"]]) %>
            <img class="mb-1" src="<%= artwork["imageUrl"] %>" />
            <div class="mb-0_5 sans-2-medium"> <%= Money.to_string(Money.new(event.payload["properties"]["buyer_total_cents"], :USD)) %> </div>
            <div class="serif-2-semibold color-black60"> <%= artwork["artist_names"] %> </div>
            <div class="serif-2-italic color-black60"> <%= artwork["title"] %> </div>
            <div class="serif-2 color-black60"> <%= artwork["partner"]["name"] %> </div>
            <div class="serif-2 color-black30"> <a href="<%= exchange_link(event.payload["object"]["id"]) %>"> <%= event.payload["properties"]["code"] %></a></div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket) do
      AprWeb.Endpoint.subscribe("events")
      send(self(), :initialize)
    end

    {:ok, assign(socket, events: [], totals: %{amount_cents: 0, commission_cents: 0})}
  end

  def handle_info(:initialize, socket) do
    case Events.get_order_events do
      {:ok, results} -> {:noreply, assign(socket, events: results.events, totals: results.totals, artworks: results.artworks) }
      {:error, error} -> raise error
    end
  end

  def handle_info(%{event: "new_event", payload: _event}, socket) do
    case Events.get_order_events do
      {:ok, results} -> {:noreply , assign(socket, events: results.events, totals: results.totals, artworks: results.artworks) }
      {:error, error} -> raise error
    end
  end
end
