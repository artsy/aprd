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

  def tax_mismatch_error_event() do
    %{
      "object" => %{
        "id" => "ApplicationError",
        "display" => "ApplicationError"
      },
      "properties" => %{
        "type" => "processing",
        "code" => "tax_mismatch",
        "data" => %{
          "order_id" => "order1",
          "tax_transaction_id" => "avalara_id"
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

  def commerce_transaction_event(order \\ nil, properties \\ %{}) do
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
        "failure_code" => "do_not_honor",
        "failure_message" => ":(",
        "transaction_type" => "capture"
      }
      |> Map.merge(properties)
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
          "payment_method" => "credit card",
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


   # event.properties
  # {:id=>"722c4b90-856f-4db8-b25b-c7c7b51e3925", :response_payload=>{"status"=>"disqualified"}, :order=>{:id=>"b4be2ae9-bc6a-4f7d-9f92-8a368f820e32", :artsy_total_cents=>nil, :artwork_details=>nil, :buyer_id=>"user-id-0", :buyer_phone_number=>nil, :buyer_total_cents=>nil, :buyer_type=>"user", :code=>"677258267", :commission_fee_cents=>nil, :commission_rate=>nil, :conditions_of_sale=>nil, :created_at=>Fri, 07 Jul 2023 12:34:48.847234000 UTC +00:00, :currency_code=>"USD", :external_charge_id=>nil, :fulfilled_by_admin_id=>nil, :fulfillment_type=>nil, :impulse_conversation_id=>nil, :items_total_cents=>nil, :mode=>"buy", :order_update_state=>nil, :payment_method=>nil, :payment_method_id=>nil, :seller_id=>"partner-id-0", :seller_total_cents=>nil, :seller_type=>"gallery", :shipping_address_line1=>nil, :shipping_address_line2=>nil, :shipping_city=>nil, :shipping_country=>nil, :shipping_name=>nil, :shipping_postal_code=>nil, :shipping_region=>nil, :shipping_total_cents=>nil, :shipping_radius=>nil, :source=>"artwork_page", :state=>"pending", :state_expires_at=>Sun, 09 Jul 2023 12:34:48.846873000 UTC +00:00, :state_reason=>nil, :tax_total_cents=>nil, :tax_types=>[], :total_list_price_cents=>10000, :transaction_fee_cents=>nil, :updated_at=>Fri, 07 Jul 2023 12:34:48.856951000 UTC +00:00, :wire_credit_memo_key=>nil}}

#   full event:
  #<ShippingQuoteRequestEvent:0x0000000114bdcbe8 @subject="user-1", @verb="disqualified", @object=#<ShippingQuoteRequest id: "722c4b90-856f-4db8-b25b-c7c7b51e3925", line_item_id: "3806df8d-63b2-413d-aa7d-137c0a29f275", external_id: "316e5f704c7572b4789e", response_payload: {"status"=>"disqualified"}, internal_reference: nil, public_reference: nil, quoted_at: nil, expires_at: nil, created_at: "2023-07-07 12:34:49.024181000 +0000", updated_at: "2023-07-07 12:34:49.024181000 +0000", disqualifications: nil>, @order=#<Order id: "b4be2ae9-bc6a-4f7d-9f92-8a368f820e32", code: "677258267", shipping_total_cents: nil, tax_total_cents: nil, transaction_fee_cents: nil, commission_fee_cents: nil, currency_code: "USD", buyer_id: "user-id-0", seller_id: "partner-id-0", created_at: "2023-07-07 12:34:48.847234000 +0000", updated_at: "2023-07-07 12:34:48.856951000 +0000", state: "pending", credit_card_id: nil, state_updated_at: "2023-07-07 12:34:48.846873000 +0000", state_expires_at: "2023-07-09 12:34:48.846873000 +0000", shipping_address_line1: nil, shipping_address_line2: nil, shipping_city: nil, shipping_country: nil, shipping_postal_code: nil, fulfillment_type: nil, shipping_region: nil, external_charge_id: nil, shipping_name: nil, buyer_type: "user", seller_type: "gallery", items_total_cents: nil, buyer_total_cents: nil, seller_total_cents: nil, buyer_phone_number: nil, state_reason: nil, commission_rate: nil, mode: "buy", last_offer_id: nil, original_user_agent: nil, original_user_ip: nil, payment_method: nil, assisted: nil, fulfilled_by_admin_id: nil, impulse_conversation_id: nil, source: "artwork_page", bank_account_id: nil, shipping_radius: nil, shipping_fee_filled_on_order: false, location_filled_on_order: false, buyer_phone_number_country_code: nil, invoice_finalized: false, conditions_of_sale: nil, artwork_details: nil, submitted_at: nil, submitted_from_ip: nil, authorized_payment_methods: []>>
  def shipping_quote_disqualified_event(verb \\ "disqualified", properties \\ %{}) do
    %{  
      "object" => %{
        "id" => "shipping-quote-request-id",
        "external_id" => "123"
      },
      "subject" => %{
        "id" => "user1",
      },
      "verb" => verb,
      "properties" => %{
        "order" => %{
          "id" => "order-id-hello"
        },
      }
      |> Map.merge(properties)
    }
  end

  def auction_results_artist_change_event(old_artist_id \\ "old", artist_id \\ "new")

  def auction_results_artist_change_event(old_artist_id, nil) do
    %{
      "verb" => "artist_change",
      "subject" => nil,
      "object" => %{
        "id" => "751294",
        "root_type" => "Lot",
        "display" => "The Fall by Richard Bosman, #126 at Christie's: Contemporary Edition (2022-03-09)"
      },
      "properties" => %{
        "old_artist_id" => old_artist_id,
        "artist_id" => nil,
        "match" => nil,
        "maker_text" => "Richard Bosman"
      }
    }
  end

  def auction_results_artist_change_event(old_artist_id, artist_id) do
    %{
      "verb" => "artist_change",
      "subject" => nil,
      "object" => %{
        "id" => "751294",
        "root_type" => "Lot",
        "display" => "The Fall by Richard Bosman, #126 at Christie's: Contemporary Edition (2022-03-09)"
      },
      "properties" => %{
        "old_artist_id" => old_artist_id,
        "artist_id" => artist_id,
        "match" => %{
          "_index" => "artists_staging",
          "_type" => "_doc",
          "_id" => "5c19768dddcc7a07c5c34572",
          "_score" => 224.4639,
          "_source" => %{
            "alternate_names" => nil,
            "nationality" => [
              "American"
            ],
            "follow_count" => 18,
            "name" => "RICHARD BOSMAN",
            "name_exact" => "richard bosman",
            "birth_year" => "1944-01-01"
          }
        },
        "maker_text" => "Richard Bosman"
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

  def seller_event(verb \\ "created", properties \\ %{}) do
    %{
      "object" => %{
        "id" => "transaction123",
        "display" => "Transaction(123)"
      },
      "subject" => %{
        "id" => "user1",
        "display" => "User LastName"
      },
      "verb" => verb,
      "properties" => %{
        "partner_id" => "1",
        "artwork_groups" => [],
        "invoice" => %{
          "artwork_groups" => []
        },
        "external_id" => "stripe_account_id",
      }
      |> Map.merge(properties)
    }
  end
end
