defmodule Apr.JwtToken do
  use Joken.Config

  def token_config do
    aud = Application.get_env(:apr,ArtsyOAuth)[:jwt_aud]
    %{}
    |> Joken.Config.add_claim("aud", fn -> aud end, &(&1 == aud))
  end
end
