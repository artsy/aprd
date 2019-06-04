defmodule AprWeb.OrderDashboardLive do
  use Phoenix.LiveView
  import Apr.ViewHelper
  alias Apr.Events

  def render(assigns) do
    ~L"""
    <div class="main-live">
      <section class="main-stats">
        <palette-jumbo label="GMV (last 24 hrs)">
          <%= currency(@approved_orders.totals.amount_cents) %>
        </palette-jumbo>
        <palette-jumbo label="Commission (last 24 hrs)">
          <%= currency(@approved_orders.totals.commission_cents) %>
        </palette-jumbo>
        <palette-jumbo label="Pending Approval GMV">
          <%= currency(@active_orders.totals.amount_cents) %>
        </palette-jumbo>
        <palette-jumbo label="Pending Approval Commission">
          <%= currency(@active_orders.totals.commission_cents) %>
        </palette-jumbo>
      </section>
      <section class="main-stats">
        <palette-jumbo label="Yesterday's GMV">
          <%= currency(@approved_yesterday.totals.amount_cents) %>
        </palette-jumbo>

        <palette-jumbo label="Today's GMV">
          <%= currency(@approved_today.totals.amount_cents) %>
        </palette-jumbo>
      </section>
      <section class="stats-details">
        <section class="event">
          <h2 class="sans-6"> Approved (<%= @approved_orders.count %>) </h2>
          <section class="artworks">
          <%= for event <- @approved_orders.events do %>
            <div class="artwork-event">
              <% artwork = List.first(@artworks[event.payload["object"]["id"]]) %>
              <img class="mb-1" src="<%= artwork["imageUrl"] %>" />
              <div class="mb-0_5 sans-2-medium"> <%= currency(event.payload["properties"]["items_total_cents"]) %> </div>
              <div class="serif-2-semibold color-black60"> <%= artwork["artist_names"] %> </div>
              <div class="serif-2-italic color-black60"> <%= artwork["title"] %> </div>
              <div class="serif-2 color-black60"> <%= artwork["partner"]["name"] %> </div>
              <div class="serif-2 color-black30"> <a href="<%= exchange_link(event.payload["object"]["id"]) %>"> <%= event.payload["properties"]["code"] %></a></div>
            </div>
          <% end %>
          </section>
        </section>
        <%= if !Enum.empty?(@active_orders.events) do %>
          <section class="event">
            <h2 class="sans-6"> Current Active Orders (<%= @active_orders.count %>)</h2>
            <section class="artworks">
            <%= for event <- @active_orders.events do %>
              <div class="artwork-event">
                <% artwork = List.first(@artworks[event.payload["object"]["id"]]) %>
                <img class="mb-1" src="<%= artwork["imageUrl"] %>" />
                <div class="mb-0_5 sans-2-medium"> <%= currency(event.payload["properties"]["items_total_cents"]) %> </div>
                <div class="serif-2-semibold color-black60"> <%= artwork["artist_names"] %> </div>
                <div class="serif-2-italic color-black60"> <%= artwork["title"] %> </div>
                <div class="serif-2 color-black60"> <%= artwork["partner"]["name"] %> </div>
                <div class="serif-2 color-black30"> <a href="<%= exchange_link(event.payload["object"]["id"]) %>"> <%= event.payload["properties"]["code"] %></a></div>
              </div>
            <% end %>
            </section>
          </section>
        <% end %>
      </section>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket) do
      AprWeb.Endpoint.subscribe("events")
      send(self(), :initialize)
    end

    {:ok,
     assign(socket,
       approved_orders: %{events: [], totals: %{amount_cents: 0, commission_cents: 0}, count: 0},
       active_orders: %{events: [], totals: %{amount_cents: 0, commission_cents: 0}, count: 0},
       approved_yesterday: %{events: [], totals: %{amount_cents: 0, commission_cents: 0}, count: 0},
       approved_today: %{events: [], totals: %{amount_cents: 0, commission_cents: 0}, count: 0},
       artworks: %{}
     )}
  end

  def handle_info(:initialize, socket), do: repopulate(socket)

  def handle_info(%{event: "new_event", payload: _event}, socket), do: repopulate(socket)

  defp repopulate(socket) do
    approved_order_events = Events.list_events(routing_key: "order.approved", day_threshold: 1)
    approved_yesterday = Apr.Events.list_events(routing_key: "order.approved", start_date: Date.add(Date.utc_today, -1), end_date: Date.utc_today)
    approved_today = Apr.Events.list_events(routing_key: "order.approved", start_date: Date.utc_today)
    active_orders = Events.active_orders()
    with {:ok, artworks} <-
           Events.fetch_artworks(approved_order_events ++ active_orders) do
      {:noreply,
       assign(socket,
         approved_orders: aggregated_data(approved_order_events),
         active_orders: aggregated_data(active_orders),
         approved_today: aggregated_data(approved_today),
         approved_yesterday: aggregated_data(approved_yesterday),
         artworks: artworks
       )}
    else
      [] -> {:noreply, socket}
      {:error, error} -> raise error
    end
  end

  defp aggregated_data(events) do
    %{
      events: events,
      totals: Events.get_totals(events),
      count: Enum.count(events)
    }
  end
end
