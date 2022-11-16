defmodule Apr.Views.AuctionResultsSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.AuctionResultsSlackView
  alias Apr.Fixtures

  describe "artist changed" do
    test "from one artist to another" do
      event = Fixtures.auction_results_artist_change_event
      slack_view = AuctionResultsSlackView.render(nil, event)

      assert slack_view.text == "Artist match updated for The Fall by Richard Bosman, #126 at Christie's: Contemporary Edition (2022-03-09) (#751294)"
      attachments = slack_view.attachments |> Enum.flat_map(fn a -> a.fields end) |> Enum.map(fn field -> field.value end)
      assert "<https://www.artsy.net/artist/old|old>" in attachments
      assert "<https://www.artsy.net/artist/new|RICHARD BOSMAN>" in attachments
    end

    test "from one artist to no artist (unmatched)" do
      event = Fixtures.auction_results_artist_change_event("old", nil)
      slack_view = AuctionResultsSlackView.render(nil, event)
      assert slack_view.text == "Artist match updated for The Fall by Richard Bosman, #126 at Christie's: Contemporary Edition (2022-03-09) (#751294)"
      attachments = slack_view.attachments |> Enum.flat_map(fn a -> a.fields end) |> Enum.map(fn field -> field.value end)
      assert "<https://www.artsy.net/artist/old|old>" in attachments
      assert "<https://www.artsy.net/artist/new|RICHARD BOSMAN>" not in attachments
    end

    test "from no artist (unmatched) to an artist" do
      event = Fixtures.auction_results_artist_change_event(nil)
      slack_view = AuctionResultsSlackView.render(nil, event)
      assert slack_view.text == "Artist match updated for The Fall by Richard Bosman, #126 at Christie's: Contemporary Edition (2022-03-09) (#751294)"
      attachments = slack_view.attachments |> Enum.flat_map(fn a -> a.fields end) |> Enum.map(fn field -> field.value end)
      assert "<https://www.artsy.net/artist/old|old>" not in attachments
      assert "<https://www.artsy.net/artist/new|RICHARD BOSMAN>" in attachments
    end
  end
end
