defmodule AjiWeb.PageLive do
  use AjiWeb, :live_view

  @board_size 19
  @star_points MapSet.new([{4, 4}, {15, 15}, {4, 15}, {15, 4}])

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, board_size: 19, player_color: "white", game_state: %{})}
  end

  def stone_class(game_state, player_color, i, j) do
    point = {i, j}
    cls = "stone"

    if Map.has_key?(game_state, point) do
      stone_color = Map.get(game_state, point)
      cls <> " stone-#{stone_color} stone-placed"
    else
      cls <> " stone-#{player_color} stone-hover"
    end
  end

  @impl true
  def handle_event("place-stone", %{"i" => i, "j" => j}, socket) do
    {i, _} = Integer.parse(i)
    {j, _} = Integer.parse(j)

    socket =
      socket
      |> place_stone({i, j})
      |> switch_player()

    {:noreply, socket}
  end

  def place_stone(socket, point) do
    %{game_state: game_state, player_color: player_color} = socket.assigns
    assign(socket, game_state: Map.put(game_state, point, player_color))
  end

  def switch_player(socket) do
    new_color =
      case socket.assigns.player_color do
        "black" -> "white"
        "white" -> "black"
      end

    assign(socket, player_color: new_color)
  end
end
