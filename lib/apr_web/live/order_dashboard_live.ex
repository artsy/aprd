defmodule AprWeb.OrderDashboardLive do
  use Phoenix.LiveView
  import Apr.ViewHelper
  alias Apr.Events

  def render(assigns) do
    ~L"""
    <div class="main-live">
      <section class="main-stats">
        <div class="flex flex-direction-column text-align-center">
          <div class="sans-8"> <%= Money.to_string(Money.new(@approved_orders.totals.amount_cents, :USD)) %> </div>
          <span class="sans-3">GMV</span>
        </div>
        <div class="flex flex-direction-column text-align-center">
          <div class="sans-8"> <%= Money.to_string(Money.new(@approved_orders.totals.commission_cents, :USD)) %> </div>
          <span class="sans-3">Comission</span>
        </div>
      </section>
      <section class="main-stats">
        <div class="flex flex-direction-column text-align-center">
          <div class="sans-8"> <%= Money.to_string(Money.new(@pending_approvals.totals.amount_cents, :USD)) %> </div>
          <span class="sans-3">Pending GMV</span>
        </div>
        <div class="flex flex-direction-column text-align-center">
          <div class="sans-8"> <%= Money.to_string(Money.new(@pending_approvals.totals.commission_cents, :USD)) %> </div>
          <span class="sans-3">Pending Comission</span>
        </div>
      </section>
      <div class="event-section">
        <h3> Approved </h3>
        <%= for event <- @approved_orders.events do %>
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
      <div class="event-section">
        <h3> Pending Approval </h3>
        <%= for event <- @pending_approvals.events do %>
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

    {:ok,
     assign(socket,
       approved_orders: %{events: [], totals: %{amount_cents: 0, commission_cents: 0}},
       pending_approvals: %{events: [], totals: %{amount_cents: 0, commission_cents: 0}},
       artworks: %{}
     )}
  end

  def handle_info(:initialize, socket), do: repopulate(socket)

  def handle_info(%{event: "new_event", payload: _event}, socket), do: repopulate(socket)

  defp repopulate(socket) do
    approved_order_events = Events.list_events(routing_key: "order.approved", day_threshold: 1)
    pending_approval_orders = Events.pending_approval_orders()
    with {:ok, artworks} <- Events.fetch_artworks(approved_order_events ++ pending_approval_orders) do
      {:noreply,
       assign(socket,
         approved_orders: aggregated_data(approved_order_events),
         pending_approvals: aggregated_data(pending_approval_orders),
         artworks: artworks
       )}
    else
      {:error, error} -> raise error
    end
  end

  defp aggregated_data(events) do
    %{
      events: events,
      totals: Events.get_totals(events)
    }
  end
end
