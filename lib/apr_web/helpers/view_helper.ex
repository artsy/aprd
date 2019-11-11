defmodule Apr.ViewHelper do
  @spec exchange_link(String.t()) :: String.t()
  def exchange_link(order_id) do
    "#{exchange_url()}/admin/orders/#{order_id}"
  end

  @spec currency(integer, atom | binary) :: String.t()
  def currency(amount, currency \\ :USD) do
    amount
    |> Money.new(currency)
    |> Money.to_string()
  end

  @spec exchange_user_orders_link(String.t()) :: String.t()
  def exchange_user_orders_link(user_id) do
    "#{exchange_url()}/admin/orders?q[buyer_id_eq]=#{user_id}"
    |> URI.encode()
  end

  @spec exchange_partner_orders_link(String.t()) :: String.t()
  def exchange_partner_orders_link(partner_id) do
    "#{exchange_url()}/admin/orders?q[seller_id_eq]=#{partner_id}"
    |> URI.encode()
  end

  defp exchange_url, do: Application.get_env(:apr, :exchange)[:url]
end
