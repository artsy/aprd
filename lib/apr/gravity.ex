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

  def match_partners(term, token) do
    get!("/api/v1/match/partners", [{:"X-ACCESS-TOKEN", token}], params: %{term: term}).body
    |> Enum.map(fn partner -> Map.take(partner, ["_id", "name"]) end)
  end

  def match_users(term, token) do
    get!("/api/v1/match/users", [{:"X-ACCESS-TOKEN", token}], params: %{term: term}).body
    |> Enum.map(fn partner -> Map.take(partner, ["_id", "name", "email"]) end)
  end
end
