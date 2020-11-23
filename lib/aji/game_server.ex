defmodule Aji.GameServer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, {}, opts)
  end

  @impl true
  def init(_args) do
    {:ok, %{to_move: :black, moves: []}}
  end

  @impl true
  def handle_call({:get_game_state}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:place_stone, coord}, _from, state) do
    state = state |> place_stone(coord) |> next_player()
    Phoenix.PubSub.broadcast(Aji.PubSub, "game:global", :reload)
    {:reply, {:ok, state}, state}
  end

  def place_stone(state, coord) do
    # a move is { :move, coord, color } or {:pass, color }
    Map.update!(state, :moves, fn s -> [{:move, coord, state.to_move} | s] end)
  end

  def next_player(%{to_move: :black} = state) do
    %{state | to_move: :white}
  end

  def next_player(%{to_move: :white} = state) do
    %{state | to_move: :black}
  end
end
