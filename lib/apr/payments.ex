defmodule Apr.Payments do
  @behaviour Apr.PaymentsBehaviour

  alias Stripe.PaymentIntent

  def liability_shift_happened(external_charge_id) do
    with {:ok, pi} <- PaymentIntent.retrieve(external_charge_id, %{expand: ["payment_method"]}),
         charge <- List.first(pi.charges) do
      charge.payment_method_details.card.three_d_secure.succeeded
    else
      _ -> nil
    end
  end
end