defmodule Apr.Payments do
  @behaviour Apr.PaymentsBehaviour

  alias Stripe.PaymentIntent

  def liability_shift_happened(nil), do: false
  def liability_shift_happened(external_charge_id) do
    with {:ok, pi} <- PaymentIntent.retrieve(external_charge_id, %{}),
         [charge | _tail] <- pi.charges.data,
         %{three_d_secure: three_d_secure} when is_map(three_d_secure) <-
           charge.payment_method_details.card,
         %{succeeded: succeeded} <- three_d_secure do
      succeeded
    else
      _ -> false
    end
  end
end
