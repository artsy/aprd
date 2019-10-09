defmodule Apr.PaymentsBehaviour do
  @callback liability_shift_happened(string()) :: boolean()
end
