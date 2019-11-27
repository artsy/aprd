defmodule Apr.Views.CommerceSlackView do
  alias Apr.Views.{
    CommerceTransactionSlackView,
    CommerceOfferSlackView,
    CommerceOrderSlackView,
    CommerceErrorSlackView
  }

  alias Apr.Subscriptions.{
    Subscription
  }

  def render(event, routing_key) do
    render(nil, event, routing_key)
  end

  def render(nil, event, routing_key) do
    cond do
      routing_key == "transaction.failure" ->
        CommerceTransactionSlackView.render(event, routing_key)

      routing_key =~ "offer." ->
        CommerceOfferSlackView.render(event, routing_key)

      routing_key =~ "order." ->
        CommerceOrderSlackView.render(event, routing_key)

      routing_key =~ "error." ->
        CommerceErrorSlackView.render(event, routing_key)

      true ->
        nil
    end
  end

  def render(%Subscription{theme: theme}, event, routing_key) when is_nil(theme) do
    render(nil, event, routing_key)
  end

  def render(%Subscription{theme: "fraud"}, _event, _routing_key) do
    nil
  end

  def render(_, _, _), do: nil
end
