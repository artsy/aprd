defmodule Apr.Views.FeedbacksSlackView do
  import Apr.Views.Helper
  alias Apr.Service.SentimentAnalysis

  def emoji(message) do
    message
    |> SentimentAnalysis.sentiment_score()
    |> SentimentAnalysis.sentiment_face_emoji()
  end

  def prefix(event) do
    message = event["properties"]["message"]
    ":artsy-email: #{emoji(message)}"
  end

  def obfuscate_emails(message) do
    String.replace(message, ~r/(\S+)@\S+/m, "\\1[@domain]", global: true)
  end

  def render(event) do
    %{
      text:
        "#{prefix(event)} #{cleanup_name(event["properties"]["user_name"])} #{event["verb"]} from #{
          event["properties"]["url"]
        }\n\n#{obfuscate_emails(event["properties"]["message"])}",
      attachments: [],
      unfurl_links: false
    }
  end
end
