defmodule Apr.Views.InvoiceSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.InvoiceSlackView
  import Mox

  describe "render/3" do
    test "invoice event with test routing_key" do
      event = Apr.Fixtures.invoice_event()
      slack_view = InvoiceSlackView.render(nil, event, "test")

      assert slack_view.text == ":money_with_wings: Invoice Transaction(123)"
    end

    test "invoice event with merchantaccount routing_key" do
      event = Apr.Fixtures.invoice_event()
      slack_view = InvoiceSlackView.render(nil, event, "merchantaccount")

      assert slack_view.text == ":party-parrot: Mocked Partner2 merchant account created"
    end

    test "invoice event invoicetransaction routing_key" do
      event = Apr.Fixtures.invoice_event()
      slack_view = InvoiceSlackView.render(nil, event, "invoicetransaction")

      assert slack_view.text == ":oncoming_police_car: "
    end
  end
end
