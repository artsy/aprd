defmodule AprWeb.OrderByPartner do
  use Phoenix.LiveView
  import Apr.ViewHelper
  @gravity_api Application.get_env(:apr, :gravity_api)
  @exchange_url Application.get_env(:apr, :exchange)[:url]

  def render(assigns) do
    ~L"""
    <form phx-change="suggest_partner" class="autocomplete" autocomplete="off">
      <label for="term"> Find orders by Partner </label>
      <input type="text" name="term" value="<%= @partner_query %>" list="partner_matches"
            placeholder="Search for partners..."
            <%= if @loading, do: "readonly" %> />
      <%= for match <- @partner_matches do %>
        <div class="autocompleteItem">
          <a href="<%= exchange_partner_orders_link(match["_id"]) %>" target="_blank"> <%= match["name"] %></a>
        </div>
      <% end %>
    </form>

    <form phx-change="suggest_user" class="autocomplete" autocomplete="off">
      <label for="term"> Find orders by User </label>
      <input type="text" name="term" value="<%= @partner_query %>" list="user_matches"
            placeholder="Search for user..."
            <%= if @loading, do: "readonly" %> />
      <%= for match <- @user_matches do %>
        <div class="autocompleteItem">
          <a href="<%= exchange_user_orders_link(match["_id"]) %>" target="_blank"> <%= match["name"] %> - <%= match["email"] %></a>
        </div>
      <% end %>
    </form>
    """
  end

  def mount(session, socket) do
    {:ok,
     assign(socket,
       partner_query: nil,
       user_query: nil,
       loading: false,
       partner_matches: [],
       user_matches: [],
       access_token: session.access_token
     )}
  end

  def handle_event("suggest_partner", %{"term" => term}, socket) when byte_size(term) >= 3 do
    partner_matches = fetch_partners(term, socket.assigns.access_token)
    {:noreply, assign(socket, partner_matches: partner_matches)}
  end

  def handle_event("suggest_partner", _, socket), do: {:noreply, assign(socket, partner_matches: [])}

  def handle_event("suggest_user", %{"term" => term}, socket) when byte_size(term) >= 3 do
    user_matches = fetch_users(term, socket.assigns.access_token)
    {:noreply, assign(socket, user_matches: user_matches)}
  end

  def handle_event("suggest_user", _, socket), do: {:noreply, assign(socket, user_matches: [])}

  def handle_event("select_partner" <> partner_id, _, socket) do
    {:stop,
     socket
     |> put_flash(:info, "Partner Selected")
     |> redirect(
       to: "#{@exchange_url}/admin/orders?q%5Bseller_id_eq=#{partner_id}"
     )}
  end

  defp fetch_partners(term, token) do
    @gravity_api.get!("/api/v1/match/partners", [{:"X-ACCESS-TOKEN", token}], params: %{term: term}).body
    |> Enum.map(fn partner -> Map.take(partner, ["_id", "name"]) end)
  end

  defp fetch_users(term, token) do
    @gravity_api.get!("/api/v1/match/users", [{:"X-ACCESS-TOKEN", token}], params: %{term: term}).body
    |> Enum.map(fn partner -> Map.take(partner, ["_id", "name", "email"]) end)
  end
end
