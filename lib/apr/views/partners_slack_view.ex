defmodule Apr.Views.PartnersSlackView do
  def render(event, "partner.updated") do
    %{
      text:
        ":uk: #{event["properties"]["display_name"]} has set VAT status to #{
          event["properties"]["vat_status"]
        }",
      attachments: [],
      unfurl_links: true
    }
  end
  def render(_,_), do: nil
end
