defmodule Apr.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Apr.Repo

  alias Apr.Events.Event

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events(criteria \\ []) do
    Event
    |> filter_query(criteria)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  defp filter_query(query, criteria), do: Enum.reduce(criteria, query, &event_query/2)

  defp event_query({key, value}, query) when key in ~w(topic routing_key)a do
    from e in query,
      where: field(e, ^key) == ^value
  end

  defp event_query({:payload, value}, query) when is_map(value) do
    from _e in query,
      where: fragment("(payload)::jsonb @> ?::jsonb", ^value)
  end

  defp event_query({:day_threshold, value}, query) do
    from e in query,
      where: e.inserted_at > ago(^value, "day")
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  def fetch_artworks([]), do: []

  def fetch_artworks(order_events) do
    Neuron.Config.set(url: Application.get_env(:apr, :metaphysics)[:url])

    order_id_artwork_ids =
      order_events
      |> Enum.reduce(%{}, fn e, acc ->
        artwork_ids =
          e.payload["properties"]["line_items"] |> Enum.map(fn li -> li["artwork_id"] end)

        acc
        |> Map.merge(%{e.payload["object"]["id"] => artwork_ids})
      end)

    uniq_artwork_ids = order_id_artwork_ids |> Map.values() |> List.flatten() |> Enum.uniq()

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

        artworks_order_map =
          order_id_artwork_ids
          |> Enum.reduce(%{}, fn {order_id, artwork_ids}, acc ->
            acc
            |> Map.merge(%{
              order_id => Enum.map(artwork_ids, fn artwork_id -> artworks_map[artwork_id] end)
            })
          end)

        {:ok, artworks_order_map}

      error ->
        {:error, {:could_not_fetch, error}}
    end
  end

  def get_totals(events) do
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

  def pending_approval_orders do
    query =
      from e in Event,
        where: e.routing_key == "order.pending_approval",
        where:
          fragment(
            "e0.routing_key = (select distinct on (payload->'object'->> 'id') routing_key from events where payload->'object'->> 'id' = e0.payload->'object'->>'id' order by payload->'object'->> 'id', events.inserted_at)"
          )

    Repo.all(query)
  end

  def pending_offer_response_orders do
    query =
      from e in Event,
        where: e.routing_key == "offer.pending_response",
        where:
          fragment(
            "e0.routing_key = (select distinct on (payload->'object'->> 'id') routing_key from events where payload->'object'->> 'id' = e0.payload->'object'->>'id' order by payload->'object'->> 'id', events.inserted_at)"
          )

    Repo.all(query)
  end
end
