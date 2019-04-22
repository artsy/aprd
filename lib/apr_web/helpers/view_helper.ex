defmodule Apr.ViewHelper do
  def exchange_link(order_id) do
    Application.get_env(:apr, :exchange)[:url] <> "/admin/orders/#{order_id}"
  end
end
