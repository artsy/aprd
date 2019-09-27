defmodule Apr.Views.ConsignmentsSlackView do
  @gravity_api Application.get_env(:Apr, :gravity_api)

  import Apr.ViewHelper

  def render(event) do
    artist_data = fetch_artist(event["properties"]["artist_id"])

    %{
      text: ":sparkles: #{event["properties"]["title"]} #{event["verb"]}#{thumbnail(event)}",
      attachments: [
        %{
          fields: [
            %{
              title: "Title",
              value: event["properties"]["title"],
              short: true
            },
            %{
              title: "Artist",
              value: artist_data[:name],
              short: true
            },
            %{
              title: "Year",
              value: event["properties"]["year"],
              short: true
            },
            %{
              title: "Medium",
              value: event["properties"]["medium"],
              short: true
            },
            %{
              title: "Dimensions",
              value: dimensions(event),
              short: true
            },
            %{
              title: "Provenance",
              value: event["properties"]["provenance"],
              short: true
            },
            %{
              title: "Signed",
              value: "#{event["properties"]["signature"]}",
              short: true
            },
            %{
              title: "COA",
              value: "#{event["properties"]["authenticity_certificate"]}",
              short: true
            },
            %{
              title: "Location",
              value: location(event),
              short: true
            },
            %{
              title: "Price In Mind",
              value: event["properties"]["minimum_price"],
              short: true
            },
            %{
              title: "Submission ID",
              value: event["object"]["id"],
              short: true
            },
            %{
              title: "Images",
              value: image_urls(event),
              short: false
            }
          ],
          actions: actions(event)
        }
      ],
      unfurl_links: true
    }
  end

  defp actions(event) do
    case event["verb"] do
      "submitted" ->
        [
          %{
            type: "button",
            text: "Admin Link",
            url: consignments_admin_link(event["object"]["id"])
          }
        ]

      "approved" ->
        [
          %{
            type: "button",
            text: "Make Offer",
            url: offer_link(event["properties"]["offer_link"], event["object"]["id"])
          }
        ]

      _ ->
        []
    end
  end

  defp offer_link(link, submission_id) do
    String.replace(link, "SUBMISSION_NUMBER", "#{submission_id}")
  end

  defp fetch_artist(artist_id) do
    artist_response = @gravity_api.get!("/artists/#{artist_id}").body

    %{
      permalink: artist_response["_links"]["permalink"]["href"],
      name: artist_response["name"]
    }
  end

  defp location(event) do
    "#{event["properties"]["location_city"]}, #{event["properties"]["location_state"]}, #{
      event["properties"]["location_country"]
    }"
  end

  defp dimensions(event) do
    "#{event["properties"]["width"]}x#{event["properties"]["height"]}x#{
      event["properties"]["depth"]
    }#{event["properties"]["dimensions_metric"]}"
  end

  defp thumbnail(event) do
    case event["properties"]["thumbnail"] do
      nil -> ""
      image -> "<#{image}| >"
    end
  end

  defp image_urls(event) do
    case event["properties"]["image_urls"] do
      nil ->
        ""

      images ->
        images
        |> Enum.with_index(1)
        |> Enum.map(fn {im, index} -> "<#{im}|Image #{index}>" end)
        |> Enum.join(" ")
    end
  end
end
