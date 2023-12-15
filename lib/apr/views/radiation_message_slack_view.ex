defmodule Apr.Views.RadiationMessageSlackView do
  import Apr.Views.Helper

  def render(_subscription, event) do
    %{
      text: ":sadbot: #{event["verb"]} event for #{impulse_link(event["object"]["link"])}",
      attachments: [
        %{
          fields: [
            %{
              title: "Recipient Name",
              value: "#{event["properties"]["to_name"]}",
              short: true
            },
            %{
              title: "Recipient Email",
              value: "#{event["properties"]["to_email_address"]}",
              short: true
            }
          ]
        }
      ],
      unfurl_links: false
    }
  end
end
