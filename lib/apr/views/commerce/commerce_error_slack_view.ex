# https://github.com/artsy/exchange/blob/master/app/events/application_error_event.rb

defmodule Apr.Views.CommerceErrorSlackView do
  import Apr.Views.Helper

  def render(_, event, _routing_key) do
    %{
      text: ":alert: Failed submitting an order",
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
            ] ++ data_fields(event["properties"]["data"])
        }
      ],
      unfurl_links: true
    }
  end

  defp data_fields(nil), do: []

  defp data_fields(data) do
    data
    |> Enum.map(fn {key, value} ->
      value_text =
        case key do
          "artwork_id" ->
            "<#{artwork_link(value)}|#{value}>"

          "order_id" ->
            "<#{exchange_admin_link(value)}|#{value}>"

          "seller_id" ->
            admin_partners_path = "partners/#{value}"
            "<#{admin_partners_link(admin_partners_path)}|#{value}>"

          _ ->
            value
        end

      %{
        title: key,
        value: value_text,
        short: true
      }
    end)
  end
end
