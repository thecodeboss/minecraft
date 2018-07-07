defmodule Minecraft.World do
  @moduledoc """
  Stores Minecraft world data.
  """
  use GenServer
  alias Minecraft.World.NIF
  require Logger

  @type world_opts :: [{:seed, integer}]

  @doc """
  Starts the Minecraft World, which will initialize the spawn area.
  """
  @spec start_link(world_opts) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Gets a specific chunk, loading it if necessary.

  The chunk will be already encoded into chunk sections for the client.
  """
  @spec get_chunk_data(integer, integer) :: [chunk_section :: binary]
  def get_chunk_data(x, z) do
    GenServer.call(__MODULE__, {:get_chunk_data, x, z})
  end

  #
  # Callbacks
  #

  @impl true
  def init(opts) do
    seed = Keyword.get(opts, :seed, 1230)
    :ok = NIF.set_random_seed(seed)
    init_spawn_area()
    {:ok, %{seed: seed, chunks: %{}}}
  end

  @impl true
  def handle_call({:get_chunk_data, x, z}, _from, %{chunks: chunks} = state) do
    case get_in(chunks, [x, z]) do
      nil ->
        {:ok, chunk_sections} = NIF.generate_chunk(x, z)
        chunks = Map.put_new(chunks, x, %{})
        chunks = put_in(chunks, [x, z], chunk_sections)
        {:reply, chunk_sections, %{state | chunks: chunks}}

      chunk_sections ->
        {:reply, chunk_sections, state}
    end
  end

  @impl true
  def handle_info({:load_chunk, x, z}, %{chunks: chunks} = state) do
    {:ok, chunk_sections} = NIF.generate_chunk(x, z)
    chunks = Map.put_new(chunks, x, %{})
    chunks = put_in(chunks, [x, z], chunk_sections)
    {:noreply, %{state | chunks: chunks}}
  end

  #
  # Helpers
  #

  defp init_spawn_area() do
    for x <- -8..8 do
      for z <- -8..8 do
        send(self(), {:load_chunk, x, z})
      end
    end
  end
end
