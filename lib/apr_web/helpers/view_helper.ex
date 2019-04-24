defmodule Apr.ViewHelper do
  def exchange_link(order_id) do
    Application.get_env(:apr, :exchange)[:url] <> "/admin/orders/#{order_id}"
  end

  def currency(amount, currency \\ :USD) do
    amount
    |> Money.new(currency)
    |> Money.to_string()
  end
end
