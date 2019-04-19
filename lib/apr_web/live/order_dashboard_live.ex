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
        <td><%= @totals.amount_cents %></td>
        <td><%= @totals.commission_cents %> </td>
      </td>
    </table>
    <%= for event <- @events do %>
      <div>
        <%= event.payload["properties"]["buyer_total_cents"] %>
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
    with events <- Events.list_events(routing_key: "order.approved", day_threshold: day_threshold),
        artworks <- fetch_artworks(events) do
      assign(socket, events: events, artworks: artworks, totals: get_totals(events))
    end
  end

  defp fetch_artworks(order_events) do
    Neuron.Config.set(url: "https://metaphysics-staging.artsy.net/")
    artwork_ids =
      order_events
      |> Enum.map(fn e -> e["properties"]["line_items"]["artwork_id"] end)
      |> Enum.uniq
    fetch_response = Neuron.query("""
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
      %{ids: artwork_ids})
    case fetch_response do
      {:ok, response} ->
        response.body["data"]["artworks"] |> Enum.reduce(%{}, fn a, acc -> Map.merge(acc, %{a["_id"] => a}) end )
      _ -> {:error}
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
