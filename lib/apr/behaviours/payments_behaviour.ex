defmodule Apr.PaymentsBehaviour do
  @callback payment_info(String.t(), String.t()) :: Map.t()
end
