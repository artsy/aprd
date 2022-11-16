defmodule Apr.Views.AuctionResultsSlackView do
  import Apr.Views.Helper

  def render(_subscription, event) do
    case event["verb"] do
      "artist_change" ->
        %{
          text: "Artist match updated for #{event["object"]["display"]} (##{event["object"]["id"]})",
          attachments: [
            %{
              fields: [
                %{
                  title: "Old artist id",
                  value: formatted_artist_link(event["properties"]["old_artist_id"]),
                  short: true
                },
                %{
                  title: "New artist",
                  value: formatted_artist_link(event["properties"]["artist_id"], get_in(event, ["properties", "match", "_source", "name"])),
                  short: true
                }
              ]
            }
          ],
          unfurl_links: false
        }
    end
  end
end
