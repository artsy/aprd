defmodule Apr.Views.Helper do
  @exchange_url "https://exchange.artsy.net"
  @stripe_search_url "https://dashboard.stripe.com/search"
  @gravity_api Application.get_env(:apr, :gravity_api)

  def fetch_sale_artwork(lot_id) do
    sale_artwork_response = @gravity_api.get!("/sale_artworks/#{lot_id}").body

    %{
      permalink: sale_artwork_response["_links"]["permalink"]["href"],
      lot_number: sale_artwork_response["lot_number"],
      currency: sale_artwork_response["currency"],
      estimate_cents: field_value_to_i(sale_artwork_response["estimate_cents"]),
      high_estimate_cents: field_value_to_i(sale_artwork_response["high_estimate_cents"]),
      low_estimate_cents: field_value_to_i(sale_artwork_response["low_estimate_cents"])
    }
  end

  def artwork_link(artwork_id) do
    "https://www.artsy.net/artwork/#{artwork_id}"
  end

  def artist_link(artist_id) do
    "https://www.artsy.net/artist/#{artist_id}"
  end

  def radiation_link(path) do
    "https://radiation.artsy.net/#{path}"
  end

  def impulse_link(path) do
    "https://impulse.artsy.net/#{path}"
  end

  def ohm_sale_link(path) do
    "https://auctions.artsy.net/sales/#{path}"
  end

  def artsy_sale_link(path) do
    "https://www.artsy.net/auction/#{path}"
  end

  def radiation_conversation_link(conversation_id) do
    conversation_path = "admin/accounts/2/conversations/#{conversation_id}"
    "<#{radiation_link(conversation_path)}|Conversation(#{conversation_id})>"
  end

  def impulse_conversation_link(conversation_id) do
    conversation_path = "admin/conversations/#{conversation_id}"
    "<#{impulse_link(conversation_path)}|Conversation(#{conversation_id})>"
  end

  def admin_partners_link(path) do
    "https://admin-partners.artsy.net/#{path}"
  end

  def admin_subscription_link(subscription_id) do
    admin_partners_link("subscriptions/#{subscription_id}")
  end

  def consignments_admin_link(consignment_id) do
    "https://convection.artsy.net/admin/submissions/#{consignment_id}"
  end

  def exchange_admin_link(order_id) do
    "#{@exchange_url}/admin/orders/#{order_id}"
  end

  def exchange_flag_as_fraud_link(order_id) do
    "#{@exchange_url}/admin/orders/#{order_id}/fraud_reviews/new?fraud_review[flagged_as_fraud]=true"
  end

  def exchange_not_fraud_link(order_id) do
    "#{@exchange_url}/admin/orders/#{order_id}/fraud_reviews/new"
  end

  def exchange_partner_orders_link(partner_id) do
    "#{@exchange_url}/admin/orders?q%5Bseller_id_eq=#{partner_id}"
  end

  def exchange_user_orders_link(user_id) do
    "#{@exchange_url}/admin/orders?q%5Bbuyer_id_eq=#{user_id}"
  end

  def stripe_search_link(query) when is_binary(query) do
    "#{@stripe_search_url}?#{URI.encode_query(query: query)}"
  end

  def cleanup_name(nil), do: ""

  def cleanup_name(full_name) do
    full_name
    |> String.split()
    |> List.first()
  end

  def format_price(price, currency \\ :USD, symbol \\ true) do
    if price do
      Money.to_string(Money.new(round(price), currency), symbol: symbol)
    else
      "N/A"
    end
  end

  def format_boolean(true), do: ":verified:"
  def format_boolean(false), do: ":exclamation:"

  def format_check("pass"), do: ":white_check_mark:"
  def format_check(_), do: ":x:"

  @spec field_value_to_i(nil | bitstring() | integer()) :: nil | integer()
  def field_value_to_i(nil), do: nil
  def field_value_to_i(value) when is_integer(value), do: value

  def field_value_to_i(value) when is_bitstring(value),
    do: field_value_to_i(String.to_integer(value))

  def format_datetime_string(datetime_string) when is_binary(datetime_string) do
    case DateTime.from_iso8601(datetime_string) do
      {:ok, datetime, _} -> NimbleStrftime.format(datetime, "%b %d %Y")
      _ -> "Unknown Date"
    end
  end

  def format_datetime_string(_), do: "Unknown Date"

  @spec artsy_admin_user_link(String.t()) :: String.t()
  def artsy_admin_user_link(user_id) do
    "#{artsy_admin_url()}/user/#{user_id}"
  end

  defp artsy_admin_url, do: Application.get_env(:apr, :artsy_admin)[:url]
end
