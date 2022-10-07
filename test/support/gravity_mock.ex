defmodule GravityMock do
  def get!("/v1/user/" <> id) do
    %{
      body: %{
        "id" => id,
        "name" => "Mocked User2",
        "created_at" => "2019-11-04T23:35:09+00:00"
      }
    }
  end

  def get!("/v1/partner/" <> id) do
    %{
      body: %{
        "id" => id,
        "name" => "Mocked Partner2"
      }
    }
  end

  def get!("/partners/" <> id) do
    %{
      body: %{
        "id" => id,
        "name" => "Mocked Partner2"
      }
    }
  end

  def get!("/v1/artwork/" <> artwork_id) do
    %{
      body: %{
        "id" => artwork_id,
        "ecommerce" => true,
        "offer" => true
      }
    }
  end

  def get!("/v1/sale/" <> sale_id) do
    %{
      body: %{
        "id" => sale_id,
        "sale_type" => "big one",
        "eligible_sale_artworks_count" => "2"
      }
    }
  end

  def match_partners(_term, _token) do
    %{}
  end

  def match_users(_term, _token) do
    %{}
  end
end
