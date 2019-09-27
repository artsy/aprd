defmodule Apr.Service.SentimentAnalysisService do
  def sentiment_score(text) do
    Sentient.analyze(text)
  end

  def sentiment_face_emoji(score) do
    case score do
      score when score >= 2 -> ":simple_smile:"
      score when score <= -2 -> ":frowning:"
      _ -> ":neutral_face:"
    end
  end
end
