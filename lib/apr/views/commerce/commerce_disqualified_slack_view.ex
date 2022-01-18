defmodule Apr.Views.CommerceDisqualifiedSlackView do
    import Apr.Views.Helper
    alias Apr.Subscriptions.Subscription
  
    def render(%Subscription{theme: "fraud"}, _, _), do: nil
  
    def render(_, event, _routing_key) do
      default_message(event)
    end
  
    defp default_message(event) do
      %{
        text: ":alert: Shipping Quote Request disqualified from ARTA",
        attachments: [
          %{
            fields:
              [
                %{
                  title: "Type",
                  value: event["properties"]["type"],
                  short: true
                },
                %{
                  title: "Code",
                  value: event["properties"]["code"],
                  short: true
                }
              ]
          }
        ],
        unfurl_links: true
      }
    end  
  end
  