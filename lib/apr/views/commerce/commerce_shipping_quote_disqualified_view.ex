defmodule Apr.Views.CommerceShippingQuoteDisqualifiedSlackView do
# #   @payments Application.get_env(:apr, :payments)

#   import Apr.Views.Helper

#   alias Apr.Views.CommerceHelper
#   alias Apr.Subscriptions.Subscription

  def render(subscription, event, routing_key) do
    # do we need this subscription arg?
    # what is in the event object at this time in the lifecycle?
    %{
      text: ":warning: Shipping quotes cannot be generated for Artsy Shipping Order #{event["properties"]["id"]}",
      attachments: [
        %{
          fields: [
            %{
              title: "Shipping quotes cannot be generated for Order",
              value: format_arta_dashboard_link, # add link to arta dash plus like to exchange admin
              short: true
            }
          ]
        }
      ],
      unfurl_links: true
    }
  end

  defp format_arta_dashboard_link do
    #   checkout external id from the event object 
  end
end