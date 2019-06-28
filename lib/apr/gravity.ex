defmodule Gravity do
  use HTTPoison.Base

  def process_request_headers(headers),
    do:
      Keyword.merge(headers, [
        {:"X-XAPP-TOKEN", Application.get_env(:apr, Gravity)[:api_token]}
      ])

  def process_response_body(body) do
    body
    |> Jason.decode!()
  end

  def process_request_url(url) do
    Application.get_env(:apr, Gravity)[:api_url] <> url
  end
end
