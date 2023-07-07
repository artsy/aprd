defmodule Apr.Views.CommerceShippingQuoteDisqualifiedSlackView do
# #   @payments Application.get_env(:apr, :payments)

  import Apr.Views.Helper

#   alias Apr.Views.CommerceHelper
#   alias Apr.Subscriptions.Subscription

  def render(subscription, event, routing_key) do
    # do we need this subscription arg?
    # what is in the event object at this time in the lifecycle?
    %{
      text: ":warning: Shipping quotes cannot be generated for Artsy Shipping Order #{event["properties"]["order"]["id"]}",
      attachments: [
        %{
          fields: [
            %{
              title: "Shipping quotes cannot be generated for Order",
              value: formatted_exchange_admin_link(event["properties"]["order"]["id"]), # add link to arta dash plus like to exchange admin
              short: true
            }
          ]
        }
      ],
      unfurl_links: true
    }
  end

  defp formatted_exchange_admin_link(order_id) do
    "<#{exchange_admin_link(order_id)}|#{order_id}>"
  end
end