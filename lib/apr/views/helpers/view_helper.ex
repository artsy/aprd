defmodule Apr.Views.Helper do
  @exchange_url "https://exchange.artsy.net"
  @stripe_search_url "https://dashboard.stripe.com/search"

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
    "https://sales.artsy.net/sales/#{path}"
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

  def format_boolean(true), do: "Yes"
  def format_boolean(false), do: "No"
end
