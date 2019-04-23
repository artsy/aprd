defmodule Apr.EventsTest do
  use Apr.DataCase

  alias Apr.Events

  describe "events" do
    alias Apr.Events.Event

    @valid_attrs %{topic: "test", routing_key: "test.created", payload: %{}}
    @update_attrs %{topic: "test", routing_key: "test.updated", payload: %{}}
    @invalid_attrs %{payload: nil}

    def event_fixture(attrs \\ %{}) do
      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Events.create_event()

      event
    end

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
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
