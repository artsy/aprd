defmodule Apr.EventsTest do
  use Apr.DataCase

  describe "events" do
    alias Apr.Events
    alias Apr.Events.Event
    alias Apr.Fixtures

    @valid_attrs %{topic: "test", routing_key: "test.created", payload: %{}}
    @invalid_attrs %{payload: nil}

    test "list_events/0 returns all events" do
      event = Fixtures.create(:event, @valid_attrs)
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = Fixtures.create(:event, @valid_attrs)
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Events.create_event(@valid_attrs)
      assert event.payload == %{}
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end
  end
end
