defmodule Apr.Views.SubscriptionSlackView do
  import Apr.Views.Helper

  def render(_subscription, event) do
    %{
      text: "",
      attachments: [
        %{
          title: ":moneybag: #{event["properties"]["partner"]["name"]}'s subscription #{event["verb"]}",
          title_link: "#{admin_subscription_link(event["object"]["id"])}",
          fields: [
            %{
              title: "Outreach Admin",
              value: "#{event["properties"]["partner"]["outreach_admin"]}",
              short: true
            },
            %{
              title: "First Subscription?",
              value: "#{event["properties"]["partner"]["initial_subscription"]}",
              short: true
            }
          ]
        }
      ],
      unfurl_links: false
    }
  end
end
