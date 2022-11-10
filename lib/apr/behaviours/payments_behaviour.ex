defmodule Apr.PaymentsBehaviour do
  @callback payment_info(String.t(), String.t()) :: Map.t()
  @callback payment_info_ach(String.t(), String.t()) :: Map.t()
end
