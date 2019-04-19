defmodule AprWeb.OrderDashboardLive do
  use Phoenix.LiveView
  alias Apr.Events

  def render(assigns) do
    ~L"""
    <button phx-click="today">Today</button>
    <button phx-click="last_week">Last 7 Days</button>
    <button phx-click="last_month">Last Month</button>
    <table>
      <tr>
        <th> GMV </th>
        <th> Commission </th>
      </tr>
      <tr>
        <td>$<%= @totals.amount_cents / 100 %></td>
        <td>$<%= @totals.commission_cents / 100 %> </td>
      </td>
    </table>
    <%= for event <- @events do %>
      <div>
        <div> <%= List.first(@artworks[event.payload["object"]["id"]])["title"] %> </div>
        <div> <%= List.first(@artworks[event.payload["object"]["id"]])["artist_names"] %> </div>
        <img src="<%= List.first(@artworks[event.payload["object"]["id"]])["imageUrl"] %>" />
      </div>
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
    with events <-
           Events.list_events(routing_key: "order.approved", day_threshold: day_threshold),
         artworks <- fetch_artworks(events) do
      assign(socket, events: events, artworks: artworks, totals: get_totals(events))
    end
  end

  defp fetch_artworks([]), do: []

  defp fetch_artworks(order_events) do
    Neuron.Config.set(url: "https://metaphysics-staging.artsy.net/")

    order_id_artwork_ids =
      order_events
      |> Enum.reduce(%{}, fn e, acc ->
        artwork_ids =
          e.payload["properties"]["line_items"] |> Enum.map(fn li -> li["artwork_id"] end)

        acc
        |> Map.merge(%{e.payload["object"]["id"] => artwork_ids})
      end)

    uniq_artwork_ids =
      order_id_artwork_ids |> Map.values() |> List.flatten() |> Enum.uniq()

    fetch_response =
      Neuron.query(
        """
          query orderArtworks($ids: [String]) {
            artworks(ids: $ids) {
              id
              _id
              title
              artist {
                name
              }
              partner {
                name
              }
              imageUrl
            }
          }
        """,
        %{ids: uniq_artwork_ids}
      )

    case fetch_response do
      {:ok, response} ->
        artworks_map =
          response.body["data"]["artworks"]
          |> Enum.reduce(%{}, fn a, acc -> Map.merge(acc, %{a["_id"] => a}) end)

        order_id_artwork_ids
        |> Enum.reduce(%{}, fn {order_id, artwork_ids}, acc ->
          acc
          |> Map.merge(%{
            order_id => Enum.map(artwork_ids, fn artwork_id -> artworks_map[artwork_id] end)
          })
        end)

      _ ->
        {:error}
    end
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
