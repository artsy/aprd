defmodule Apr.Service.SentimentAnalysisTest do
  use ExUnit.Case, async: true
  alias Apr.SentimentAnalysis

  describe "SentimentAnalysisTest.sentiment_face_emoji/1" do
    test "with a low score" do
      response = SentimentAnalysis.sentiment_face_emoji(-5)
      assert response == ":frowning:"
    end

    test "with a neutral score" do
      response = SentimentAnalysis.sentiment_face_emoji(0)
      assert response == ":neutral_face:"
    end

    test "with a high score" do
      response = SentimentAnalysis.sentiment_face_emoji(5)
      assert response == ":simple_smile:"
    end
  end
end
