defmodule AjiWeb.PageLive do
  use AjiWeb, :live_view

  @board_size 19
  @star_points MapSet.new(for i <- [4, 10, 16], j <- [4, 10, 16], do: {i, j})

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Aji.PubSub, "game:global")
    {:ok, load_game_state(socket)}
  end

  @impl true
  def handle_info(:reload, socket) do
    {:noreply, load_game_state(socket)}
  end

  @impl true
  def handle_event("place-stone", %{"i" => i, "j" => j}, socket) do
    {i, _} = Integer.parse(i)
    {j, _} = Integer.parse(j)

    socket =
      socket
      |> place_stone({i, j})

    {:noreply, socket}
  end

  defp stone_class(board_state, player_color, i, j) do
    point = {i, j}

    if Map.has_key?(board_state, point) do
      stone_color = Map.get(board_state, point)
      "stone stone-#{stone_color} stone-placed"
    else
      "stone stone-#{player_color} stone-hover"
    end
  end

  defp place_stone(socket, point) do
    {:ok, %{to_move: player_color, moves: moves}} =
      GenServer.call(Aji.GameServer, {:place_stone, point})

    assign(socket, board_state: moves_to_board_state(moves), player_color: player_color)
  end

  def is_star_point(i, j) do
    MapSet.member?(@star_points, {i, j})
  end

  defp load_game_state(socket) do
    game_state = GenServer.call(Aji.GameServer, {:get_game_state})

    assign(socket,
      board_size: 19,
      player_color: game_state.to_move,
      board_state: moves_to_board_state(game_state.moves)
    )
  end

  defp moves_to_board_state(moves) do
    # FIXME: handle passes
    Enum.reduce(moves, %{}, fn {:move, coord, color}, state ->
      Map.put(state, coord, color)
    end)
  end
end
