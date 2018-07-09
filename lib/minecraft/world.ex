defmodule Minecraft.World do
  @moduledoc """
  Stores Minecraft world data.
  """
  use GenServer
  alias Minecraft.NIF
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
  @spec get_chunk(integer, integer) :: Minecraft.Chunk.t()
  def get_chunk(x, z) do
    GenServer.call(__MODULE__, {:get_chunk, x, z})
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
  def handle_call({:get_chunk, x, z}, _from, %{chunks: chunks} = state) do
    case get_in(chunks, [x, z]) do
      nil ->
        {:ok, chunk} = NIF.generate_chunk(x, z)
        chunk = %Minecraft.Chunk{resource: chunk}
        chunks = Map.put_new(chunks, x, %{})
        chunks = put_in(chunks, [x, z], chunk)
        {:reply, chunk, %{state | chunks: chunks}}

      chunk_sections ->
        {:reply, chunk_sections, state}
    end
  end

  @impl true
  def handle_info({:load_chunk, x, z}, %{chunks: chunks} = state) do
    case get_in(chunks, [x, z]) do
      nil ->
        {:ok, chunk} = NIF.generate_chunk(x, z)
        chunk = %Minecraft.Chunk{resource: chunk}
        chunks = Map.put_new(chunks, x, %{})
        chunks = put_in(chunks, [x, z], chunk)
        {:noreply, %{state | chunks: chunks}}

      _chunk_sections ->
        {:noreply, state}
    end
  end

  #
  # Helpers
  #

  defp init_spawn_area() do
    for x <- -20..20 do
      for z <- -20..20 do
        send(self(), {:load_chunk, x, z})
      end
    end
  end
end
