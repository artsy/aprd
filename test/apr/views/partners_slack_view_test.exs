defmodule Apr.Views.PartnersSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.PartnersSlackView
  alias Apr.Fixtures

  describe "partner created" do
    test "we return nil" do
      event = Fixtures.partner_update_event("created")
      slack_view = PartnersSlackView.render(nil, event, "partnergallery.created")
      assert slack_view == nil
    end
  end

  describe "partner updated" do
    test "VAT was updated we return proper message" do
      event = Fixtures.partner_update_event("updated", ["vat_status", "name"])
      slack_view = PartnersSlackView.render(nil, event, "partnergallery.updated")
      assert slack_view.text == ":uk: Invoicing Demo Partner has set VAT status to registered"
    end

    test "VAT was not updated we return nil" do
      event = Fixtures.partner_update_event("updated", ["updated_at"])
      slack_view = PartnersSlackView.render(nil, event, "partnergallery.updated")
      assert slack_view == nil
    end
  end
end
