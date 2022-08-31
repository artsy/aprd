defmodule Apr.Views.CommerceSlackView do
  alias Apr.Views.{
    CommerceTransactionSlackView,
    CommerceTransactionCreatedSlackView,
    CommerceOfferSlackView,
    CommerceOrderSlackView,
    CommerceErrorSlackView
  }

  def render(subscription, event, routing_key) do
    cond do
      routing_key == "transaction.failure" ->
        CommerceTransactionSlackView.render(subscription, event, routing_key)

      routing_key == "transaction.created" ->
        CommerceTransactionCreatedSlackView.render(subscription, event, routing_key)

      routing_key =~ "offer." ->
        CommerceOfferSlackView.render(subscription, event, routing_key)

      routing_key =~ "order." ->
        CommerceOrderSlackView.render(subscription, event, routing_key)

      routing_key =~ "error." ->
        CommerceErrorSlackView.render(subscription, event, routing_key)

      true ->
        nil
    end
  end
end
