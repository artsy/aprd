defmodule Apr.Views.CommerceErrorSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.CommerceErrorSlackView

  test "commerce error slack view" do
    event = Apr.Fixtures.commerce_error_event()
    slack_view = CommerceErrorSlackView.render(event, "test_routing_key")
    assert slack_view.text == ":alert: Failed submitting an order"

    assert Enum.map(List.first(slack_view.attachments).fields, fn field -> field.title end) == [
             "Type",
             "Code",
             "order_id"
           ]

    assert slack_view[:unfurl_links] == true
  end
end
