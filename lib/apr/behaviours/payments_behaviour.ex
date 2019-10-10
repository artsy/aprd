defmodule Apr.PaymentsBehaviour do
  @callback liability_shift_happened(String.t()) :: boolean()
end
