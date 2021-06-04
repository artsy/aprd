defmodule Apr.Fixtures do
  alias Apr.Subscriptions
  alias Apr.Events

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

  def commerce_offer_order(verb \\ "submitted", properties \\ %{}),
    do: commerce_order_event(verb, properties |> Map.merge(%{"mode" => "offer"}))

  def commerce_order_event(verb \\ "submitted", properties \\ %{}) do
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
      "properties" =>
        %{
          "mode" => "buy",
          "impulse_conversation_id" => nil,
          "state_reason" => nil,
          "seller_id" => "partner1",
          "seller_type" => "gallery",
          "buyer_id" => "user1",
          "buyer_type" => "user",
          "currency_code" => "USD",
          "items_total_cents" => 20000_00,
          "total_list_price_cents" => 3000,
          "external_charge_id" => "pi_1",
          "line_items" => [
            %{
              "id" => "li-1",
              "artwork_id" => "artwork1"
            }
          ]
        }
        |> Map.merge(properties)
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

  def partner_update_event(verb \\ "updated", changes \\ []) do
    %{
      "verb" => verb,
      "subject" => nil,
      "object" => %{
        "id" => "581b45e4cd530e658b000124",
        "root_type" => "PartnerGallery",
        "display" => "Invoicing Demo Partner"
      },
      "properties" => %{
        "created_at" => "2016-11-03 14:12:52 UTC",
        "updated_at" => "2019-10-07 18:52:31 UTC",
        "admin" => %{
          "id" => nil,
          "name" => nil
        },
        "outreach_admin" => %{
          "id" => nil,
          "name" => nil
        },
        "changes" => changes,
        "given_name" => "Invoicing Demo Partner",
        "display_name" => "",
        "short_name" => "",
        "slug" => "invoicing-demo-partner",
        "alternate_names" => [
          "Partner Success Invoicing Demo Partner"
        ],
        "featured_names" => nil,
        "subscription_state" => "active",
        "billing_day" => 1,
        "contract_type" => "Subscription",
        "partner_flags" => %{
          "reporting_category" => "gallery",
          "last_cms_access" => "2019-10-05T20:39:57.096Z",
          "legal_agreements" => "2016-11-03T14:24:27.723+00:00",
          "cms_welcome_accepted" => "2016-11-03T14:24:27.895+00:00",
          "last_folio_access" => "2017-03-22",
          "ecommerce" => "true",
          "gdpr_dpa_accepted" => "2019-04-12T20:15:38.550+00:00",
          "updated_legal_agreements" => "2019-04-16T12:10:33.851+00:00"
        },
        "vat_status" => "registered"
      }
    }
  end
end
