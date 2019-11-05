defmodule Apr.Views.PartnersSlackView do
  def render(event = %{"verb" => "updated", "properties" => %{"changes" => changes}}, _) do
    if Enum.member?(changes, "vat_status") do
      %{
        text: ":uk: #{event["properties"]["given_name"]} has set VAT status to #{event["properties"]["vat_status"]}",
        attachments: [],
        unfurl_links: true
      }
    else
      nil
    end
  end

  def render(_, _), do: nil
end
