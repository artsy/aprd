defmodule Apr.Payments do
  @behaviour Apr.PaymentsBehaviour

  alias Stripe.PaymentIntent

  def payment_info(external_id, "payment_intent") do
    with {:ok, pi} <- PaymentIntent.retrieve(external_id, %{expand: ["payment_method"]}),
         liability_shift <- liability_shift_from_payment(pi),
         charge_data <- charge_data(pi) do
      {:ok,
       %{
         liability_shift: liability_shift,
         charge_data: charge_data,
         card_country: pi.last_payment_error.payment_method.card.country,
         cvc_check: pi.last_payment_error.payment_method.card.checks.cvc_check,
         zip_check: pi.last_payment_error.payment_method.card.checks.address_postal_code_check,
         billing_state: pi.last_payment_error.payment_method.billing_details.address.state
       }}
    else
      _ -> nil
    end
  end

  def payment_info(_, _), do: {:uknown_payment}

  defp liability_shift_from_payment(payment_intent) do
    with [charge | _tail] <- payment_intent.charges.data,
         %{three_d_secure: three_d_secure} when is_map(three_d_secure) <- charge.payment_method_details.card,
         %{succeeded: succeeded} <- three_d_secure do
      succeeded
    else
      _ -> false
    end
  end

  defp charge_data(payment_intent) do
    with [charge | _tail] <- payment_intent.charges.data do
      %{
        risk_level: charge.outcome.risk_level,
        fraud_details: charge.fraud_details
      }
    else
      _ -> %{}
    end
  end
end
