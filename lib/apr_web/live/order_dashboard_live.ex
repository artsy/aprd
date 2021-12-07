defmodule AprWeb.OrderDashboardLive do
  use Phoenix.LiveView
  import Apr.ViewHelper
  alias Apr.Events

  def render(assigns) do
    ~L"""
    <div class="main-live">
      <section class="main-stats">
        <palette-jumbo label="">
          🇺🇸
        </palette-jumbo>
        <palette-jumbo label="Pending Approval GMV">
          <%= currency(@active_orders_usd.totals.amount_cents) %>
        </palette-jumbo>
        <palette-jumbo label="Today's GMV">
          <%= currency(@approved_today_usd.totals.amount_cents) %>
        </palette-jumbo>
        <palette-jumbo label="Yesterday's GMV">
          <%= currency(@approved_yesterday_usd.totals.amount_cents) %>
        </palette-jumbo>
        <palette-jumbo label="Current Month's GMV">
          <%= currency(@current_month_usd.totals.amount_cents) %>
        </palette-jumbo>
      </section>
      <section class="main-stats">
        <palette-jumbo label="">
          🇬🇧
        </palette-jumbo>
        <palette-jumbo label="Pending Approval GMV">
          <%= currency(@active_orders_gbp.totals.amount_cents, "GBP") %>
        </palette-jumbo>
        <palette-jumbo label="Today's GMV">
          <%= currency(@approved_today_gbp.totals.amount_cents, "GBP") %>
        </palette-jumbo>
        <palette-jumbo label="Yesterday's GMV">
          <%= currency(@approved_yesterday_gbp.totals.amount_cents, "GBP") %>
        </palette-jumbo>
        <palette-jumbo label="Current Month's GMV">
          <%= currency(@current_month_gbp.totals.amount_cents, "GBP") %>
        </palette-jumbo>
      </section>
      <section class="main-stats">
        <palette-jumbo label="">
          🇪🇺
        </palette-jumbo>
        <palette-jumbo label="Pending Approval GMV">
          <%= currency(@active_orders_eur.totals.amount_cents, "EUR") %>
        </palette-jumbo>
        <palette-jumbo label="Today's GMV">
          <%= currency(@approved_today_eur.totals.amount_cents, "EUR") %>
        </palette-jumbo>
        <palette-jumbo label="Yesterday's GMV">
          <%= currency(@approved_yesterday_eur.totals.amount_cents, "EUR") %>
        </palette-jumbo>
        <palette-jumbo label="Current Month's GMV">
          <%= currency(@current_month_eur.totals.amount_cents, "EUR") %>
        </palette-jumbo>
      </section>
      <section class="stats-details">
        <section class="event">
          <h2 class="sans-6"> Approved (<%= @approved_orders_one_day.count %>) </h2>
          <section class="artworks">
          <%= for event <- @approved_orders_one_day.events do %>
            <div class="artwork-event">
              <% artwork = List.first(@artworks[event.payload["object"]["id"]]) %>
              <img class="mb-1" src="<%= artwork["imageUrl"] %>" />
              <div class="mb-0_5 sans-2-medium"> <%= currency(event.payload["properties"]["items_total_cents"], event.payload["properties"]["currency_code"]) %> </div>
              <div class="serif-2-semibold color-black60"> <%= artwork["artistNames"] %> </div>
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
                <div class="mb-0_5 sans-2-medium"> <%= currency(event.payload["properties"]["items_total_cents"], event.payload["properties"]["currency_code"]) %> </div>
                <div class="serif-2-semibold color-black60"> <%= artwork["artistNames"] %> </div>
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
       approved_orders_one_day: aggregated_data(nil),
       active_orders: aggregated_data(nil),
       active_orders_usd: aggregated_data(nil),
       active_orders_gbp: aggregated_data(nil),
       active_orders_eur: aggregated_data(nil),
       approved_yesterday_usd: aggregated_data(nil),
       approved_today_usd: aggregated_data(nil),
       current_month_usd: aggregated_data(nil),
       approved_yesterday_gbp: aggregated_data(nil),
       approved_today_gbp: aggregated_data(nil),
       current_month_gbp: aggregated_data(nil),
       approved_yesterday_eur: aggregated_data(nil),
       approved_today_eur: aggregated_data(nil),
       current_month_eur: aggregated_data(nil),
       artworks: %{}
     )}
  end

  def handle_info(:initialize, socket), do: repopulate(socket)

  def handle_info(%{event: "new_event", payload: _event}, socket), do: repopulate(socket)

  def handle_info(:usd_numbers, socket) do
    nyc_time = NaiveDateTime.add(NaiveDateTime.utc_now(), -4 * 60 * 60, :second)

    approved_yesterday_usd =
      Events.list_events(
        routing_key: "order.approved",
        payload: %{properties: %{currency_code: "USD"}},
        start_date: Date.add(nyc_time, -1),
        end_date: NaiveDateTime.to_date(nyc_time)
      )

    approved_today_usd =
      Events.list_events(
        routing_key: "order.approved",
        payload: %{properties: %{currency_code: "USD"}},
        start_date: NaiveDateTime.to_date(nyc_time)
      )

    current_month_usd =
      Events.list_events(
        routing_key: "order.approved",
        payload: %{properties: %{currency_code: "USD"}},
        start_date: %{NaiveDateTime.to_date(nyc_time) | day: 1}
      )

    {:noreply,
     assign(socket,
       approved_today_usd: aggregated_data(approved_today_usd),
       approved_yesterday_usd: aggregated_data(approved_yesterday_usd),
       current_month_usd: aggregated_data(current_month_usd)
     )}
  end

  def handle_info(:gbp_numbers, socket) do
    nyc_time = NaiveDateTime.add(NaiveDateTime.utc_now(), -4 * 60 * 60, :second)

    approved_yesterday_gbp =
      Events.list_events(
        routing_key: "order.approved",
        payload: %{properties: %{currency_code: "GBP"}},
        start_date: Date.add(nyc_time, -1),
        end_date: NaiveDateTime.to_date(nyc_time)
      )

    approved_today_gbp =
      Events.list_events(
        routing_key: "order.approved",
        payload: %{properties: %{currency_code: "GBP"}},
        start_date: NaiveDateTime.to_date(nyc_time)
      )

    current_month_gbp =
      Events.list_events(
        routing_key: "order.approved",
        payload: %{properties: %{currency_code: "GBP"}},
        start_date: %{NaiveDateTime.to_date(nyc_time) | day: 1}
      )

    {:noreply,
     assign(socket,
       approved_today_gbp: aggregated_data(approved_today_gbp),
       approved_yesterday_gbp: aggregated_data(approved_yesterday_gbp),
       current_month_gbp: aggregated_data(current_month_gbp)
     )}
  end

  def handle_info(:eur_numbers, socket) do
    nyc_time = NaiveDateTime.add(NaiveDateTime.utc_now(), -4 * 60 * 60, :second)

    approved_yesterday_eur =
      Events.list_events(
        routing_key: "order.approved",
        payload: %{properties: %{currency_code: "EUR"}},
        start_date: Date.add(nyc_time, -1),
        end_date: NaiveDateTime.to_date(nyc_time)
      )

    approved_today_eur =
      Events.list_events(
        routing_key: "order.approved",
        payload: %{properties: %{currency_code: "EUR"}},
        start_date: NaiveDateTime.to_date(nyc_time)
      )

    current_month_eur =
      Events.list_events(
        routing_key: "order.approved",
        payload: %{properties: %{currency_code: "EUR"}},
        start_date: %{NaiveDateTime.to_date(nyc_time) | day: 1}
      )

    {:noreply,
     assign(socket,
       approved_today_eur: aggregated_data(approved_today_eur),
       approved_yesterday_eur: aggregated_data(approved_yesterday_eur),
       current_month_eur: aggregated_data(current_month_eur)
     )}
  end

  def handle_info(:active_pending_orders, socket) do
    approved_order_events = Events.list_events(routing_key: "order.approved", day_threshold: 1)
    active_orders = Events.active_orders()

    active_orders_grouped = Enum.group_by(active_orders, fn e -> e.payload["properties"]["currency_code"] end)

    with {:ok, artworks} <- Events.fetch_artworks(approved_order_events ++ active_orders) do
      {:noreply,
       assign(socket,
         approved_orders_one_day: aggregated_data(approved_order_events),
         active_orders: aggregated_data(active_orders),
         active_orders_usd: aggregated_data(active_orders_grouped["USD"]),
         active_orders_gbp: aggregated_data(active_orders_grouped["GBP"]),
         active_orders_eur: aggregated_data(active_orders_grouped["EUR"]),
         artworks: artworks
       )}
    else
      [] -> {:noreply, socket}
      {:error, _error} -> {:noreply, socket}
    end
  end

  defp repopulate(socket) do
    send(self(), :usd_numbers)
    send(self(), :gbp_numbers)
    send(self(), :eur_numbers)
    send(self(), :active_pending_orders)
    {:noreply, socket}
  end

  defp aggregated_data(nil),
    do: %{events: [], totals: %{amount_cents: 0, commission_cents: 0}, count: 0}

  defp aggregated_data(events) do
    %{
      events: events,
      totals: Events.get_totals(events),
      count: Enum.count(events)
    }
  end
end
