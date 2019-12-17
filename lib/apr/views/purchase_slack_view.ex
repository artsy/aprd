defmodule Apr.Views.PurchaseSlackView do
  import Apr.Views.Helper

  def render(_subscription, event) do
    %{
      text: ":shake: #{cleanup_name(event["subject"]["display"])} #{event["verb"]} #{artwork_link(event["properties"]["artwork"]["id"])}",
      attachments: [
        %{
          fields: [
            %{
              title: "Price",
              value: format_price((event["properties"]["sale_price"] || 0) * 100),
              short: true
            },
            %{
              title: "Partner name",
              value: event["properties"]["partner"]["name"],
              short: true
            },
            %{
              title: "Contract Type",
              value: event["properties"]["partner"]["contract_type"],
              short: true
            },
            %{
              title: "Outreach Admin",
              value: event["properties"]["partner"]["outreach_admin"],
              short: true
            },
            %{
              title: "Admin",
              value: event["properties"]["partner"]["admin"]["name"],
              short: true
            }
          ]
        }
      ],
      unfurl_links: true
    }
  end
end
