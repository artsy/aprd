defmodule Apr.Fixtures do
  alias Apr.Subscriptions
  alias Apr.Events
  @review_default_attrs %{response: true, review_type: "dobar"}

  @subscriber_attrs %{
    team_id: "team_id",
    team_domain: "team_domain",
    channel_id: "channel_id",
    channel_name: "channel_name",
    user_id: "user_id",
    user_name: "user_name"
  }

  @topic_attrs %{
    name: "cool"
  }

  @subscription_default_attrs %{
    routing_key: "random.test"
  }

  def create(type, attrs \\ %{})

  def create(:subscriber, attrs) do
    {:ok, subscriber} =
      attrs
      |> Enum.into(@subscriber_attrs)
      |> Subscriptions.create_subscriber()

    subscriber
  end

  def create(:event, attrs) do
    {:ok, event} =
      attrs
      |> Events.create_event()

    event
  end

  def create(:topic, attrs) do
    {:ok, topic} =
      attrs
      |> Enum.into(@topic_attrs)
      |> Subscriptions.create_topic()

    topic
  end

  def create(:subscription, attrs) do
    subscriber = Map.get(attrs, :subscriber, create(:subscriber))
    topic = Map.get(attrs, :topic, create(:topic))

    {:ok, subscription} =
      attrs
      |> Enum.into(@subscription_default_attrs)
      |> Enum.into(%{subscriber_id: subscriber.id, topic_id: topic.id})
      |> Subscriptions.create_subscription()

    subscription
  end

  def commerce_error_event() do
    %{
      "object" => %{
        "id" => "ApplicationError",
        "display" => "ApplicationError"
      },
      "properties" => %{
        "type" => "validation",
        "code" => "invalid_address",
        "data" => %{
          "order_id" => "order1"
        }
      }
    }
  end

  def commerce_offer_order(verb \\ "submitted", state_reason \\ nil),
    do: commerce_order_event(verb, state_reason, "offer")

  def commerce_order_event(verb \\ "submitted", state_reason \\ nil, mode \\ "buy") do
    %{
      "object" => %{
        "id" => "order123",
        "display" => "Order(1)"
      },
      "subject" => %{
        "id" => "user1",
        "display" => "User LastName"
      },
      "verb" => verb,
      "properties" => %{
        "mode" => mode,
        "state_reason" => state_reason,
        "seller_id" => "partner1",
        "seller_type" => "gallery",
        "buyer_id" => "user1",
        "buyer_type" => "user",
        "currency_code" => "USD",
        "items_total_cents" => 2_000_000,
        "total_list_price_cents" => 3000,
        "line_items" => [
          %{
            "id" => "li-1",
            "artwork_id" => "artwork1"
          }
        ]
      }
    }
  end

  def commerce_transaction_event(order \\ nil) do
    %{
      "object" => %{
        "id" => "transaction123",
        "display" => "Transaction(123)"
      },
      "subject" => %{
        "id" => "user1",
        "display" => "User LastName"
      },
      "verb" => "created",
      "properties" => %{
        "order" => order,
        "failure_code" => "insufficient_funds",
        "failure_message" => ":(",
        "transaction_type" => "capture"
      }
    }
  end

  def commerce_offer_event(verb \\ "submitted", in_response_to \\ nil) do
    %{
      "object" => %{
        "id" => "offer321",
        "display" => "Offer(321)"
      },
      "subject" => %{
        "id" => "user1",
        "display" => "User LastName"
      },
      "verb" => verb,
      "properties" => %{
        "order" => %{
          "mode" => "offer",
          "seller_id" => "partner1",
          "seller_type" => "gallery",
          "buyer_id" => "user1",
          "buyer_type" => "user",
          "currency_code" => "USD",
          "items_total_cents" => 2_000_000,
          "total_list_price_cents" => 3000,
          "line_items" => [
            %{
              "id" => "li-1",
              "artwork_id" => "artwork1"
            }
          ]
        },
        "amount_cents" => 3000,
        "from_participant" => "buyer",
        "in_response_to" => in_response_to
      }
    }
  end
end
