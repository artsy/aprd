defmodule Apr.CommandsTest do
  use Apr.DataCase

  describe ".process_command" do
    alias Apr.Commands

    test "subscriptions command" do
      params = %{
        "channel_id" => "1",
        "team_id" => "1",
        "team_domain" => "test",
        "text" => "subscriptions",
        "channel_name" => "test",
        "user_id" => "1",
        "user_name" => "test"
      }
      assert Commands.process_command(params) == %{response_type: "in_channel", text: "Subscribed topics: \n "}
    end
  end
end
