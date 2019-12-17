defmodule Apr.Subscriptions do
  @moduledoc """
  The Subscriptions context.
  """
  require Logger

  import Ecto.Query, warn: false
  alias Apr.Repo

  alias Apr.Subscriptions.{Topic, Subscription}

  @doc """
  Creates a Topic.

  ## Examples

      iex> create_topic(%{field: value})
      {:ok, %Subscriber{}}

      iex> create_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of topics.

  ## Examples

      iex> list_topics()
      [%Topic{}, ...]

  """
  def list_topics do
    Repo.all(Topic)
  end

  @doc """
  Gets a single topic.

  Raises `Ecto.NoResultsError` if the Topic does not exist.

  ## Examples

      iex> get_topic!(123)
      %Topic{}

      iex> get_topic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_topic!(id), do: Repo.get!(Topic, id)

  def get_topic_by_name(name), do: Repo.get_by(Topic, name: name)

  alias Apr.Subscriptions.Subscriber

  @doc """
  Returns the list of subscribers.

  ## Examples

      iex> list_subscribers()
      [%Subscriber{}, ...]

  """
  def list_subscribers do
    Repo.all(Subscriber)
  end

  @doc """
  Gets a single subscriber.

  Raises `Ecto.NoResultsError` if the Subscriber does not exist.

  ## Examples

      iex> get_subscriber!(123)
      %Subscriber{}

      iex> get_subscriber!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscriber!(id), do: Repo.get!(Subscriber, id)

  def get_subscriptions(topic_name, routing_key) do
    from(s in Subscription,
      join: t in Topic,
      on: t.id == s.topic_id,
      where: t.name == ^topic_name,
      where: s.routing_key == ^routing_key or is_nil(s.routing_key) or s.routing_key == "#"
    )
    |> Repo.all()
    |> Repo.preload(:subscriber)
  end

  def find_or_create_subscriber(params = %{"channel_id" => channel_id}) do
    with nil <- Repo.get_by(Subscriber, channel_id: channel_id),
         {:ok, new_subscriber} <-
           create_subscriber(
             Map.take(params, [
               "team_id",
               "team_domain",
               "channel_id",
               "channel_name",
               "user_id",
               "user_name"
             ])
           ) do
      new_subscriber
    else
      existing_subscriber -> existing_subscriber
    end
  end

  def unsubscribe(subscriber, topic_name) do
    with topic when not is_nil(topic) <- get_topic_by_name(topic_name),
         subscription when not is_nil(subscription) <-
           Repo.get_by(Subscription, subscriber_id: subscriber.id, topic_id: topic.id) do
      delete_subscription(subscription)
    else
      _ -> Logger.warn("could not delete subscription.")
    end
  end

  @doc """
  Creates a subscriber.

  ## Examples

      iex> create_subscriber(%{field: value})
      {:ok, %Subscriber{}}

      iex> create_subscriber(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscriber(attrs \\ %{}) do
    %Subscriber{}
    |> Subscriber.changeset(attrs)
    |> Repo.insert()
  end

  alias Apr.Subscriptions.Subscription

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription(attrs \\ %{}) do
    %Subscription{}
    |> Subscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single subscription.

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Topic{}

      iex> get_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription!(id), do: Repo.get!(Subscription, id)

  @doc """
  Updates a subscription.

  ## Examples

      iex> update_subscription(subscription, %{field: new_value})
      {:ok, %Subscription{}}

      iex> update_subscription(subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription(%Subscription{} = subscription, attrs) do
    subscription
    |> Subscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Subscription.

  ## Examples

      iex> delete_subscription(subscription)
      {:ok, %Subscription{}}

      iex> delete_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription changes.

  ## Examples

      iex> change_subscription(subscription)
      %Ecto.Changeset{source: %Subscription{}}

  """
  def change_subscription(%Subscription{} = subscription) do
    Subscription.changeset(subscription, %{})
  end
end
