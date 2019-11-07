defmodule Apr.Payments do
  @behaviour Apr.PaymentsBehaviour

  alias Stripe.PaymentIntent

  def payment_info(external_id, "payment_intent") do
    with {:ok, pi} <- PaymentIntent.retrieve(external_id, %{expand: ["payment_method"]}),
         charge_data <- charge_data(pi),
         payment_method <- payment_method(pi) do
      {:ok,
       %{
         charge_data: charge_data,
         card_country: payment_method.card_country,
         cvc_check: payment_method.cvc_check,
         zip_check: payment_method.zip_check,
         billing_state: payment_method.billing_state
       }}
    else
      _ -> nil
    end
  end

  def payment_info(_, _), do: {:uknown_payment}

  defp charge_data(payment_intent) do
    with [charge | _tail] <- payment_intent.charges.data do
      %{
        risk_level: charge.outcome.risk_level,
        fraud_details: charge.fraud_details,
        liability_shift: liability_shift_from_charge(charge)
      }
    else
      _ -> %{}
    end
  end

  defp liability_shift_from_charge(charge) do
    with %{three_d_secure: three_d_secure} when is_map(three_d_secure) <- charge.payment_method_details.card,
         %{succeeded: succeeded} <- three_d_secure do
      succeeded
    else
      _ -> false
    end
  end

  defp payment_method(%PaymentIntent{last_payment_error: %{payment_method: payment_method}})
       when not is_nil(payment_method) do
    payment_method_data(payment_method)
  end

  defp payment_method(%PaymentIntent{payment_method: payment_method}) when not is_nil(payment_method) do
    payment_method_data(payment_method)
  end

  defp payment_method(_) do
    %{
      card_country: nil,
      cvc_check: nil,
      zip_check: nil,
      billing_state: nil
    }
  end

  defp payment_method_data(payment_method) do
    %{
      card_country: payment_method.card.country,
      cvc_check: payment_method.card.checks.cvc_check,
      zip_check: payment_method.card.checks.address_postal_code_check,
      billing_state: payment_method.billing_details.address.state
    }
  end
end
