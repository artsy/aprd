defmodule Apr.ViewHelper do
  @exchange_url Application.get_env(:apr, :exchange)[:url]

  def exchange_link(order_id) do
    "#{@exchange_url}/admin/orders/#{order_id}"
  end

  def currency(amount, currency \\ :USD) do
    amount
    |> Money.new(currency)
    |> Money.to_string()
  end

  def exchange_user_orders_link(user_id) do
    "#{@exchange_url}/admin/orders?q%5Bbuyer_id_eq=#{user_id}"
  end

  def exchange_partner_orders_link(partner_id) do
    "#{@exchange_url}/admin/orders?q%5Bseller_id_eq=#{partner_id}"
  end
end
