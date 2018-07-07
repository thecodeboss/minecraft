defmodule Minecraft.World.NIF do
  @moduledoc """
  NIFs for doing world/chunk generation.
  """
  @on_load :load_nifs

  @doc false
  @spec load_nifs() :: :ok | {:error, any}
  def load_nifs() do
    :ok = :erlang.load_nif('./priv/world', 0)
  end

  @doc """
  Sets the random seed used for world generation.
  """
  @spec set_random_seed(integer) :: :ok
  def set_random_seed(_seed) do
    # Don't use raise here, or Dialyzer complains
    :erlang.nif_error("NIF set_random_seed/1 not implemented")
  end

  @doc """
  Generates a chunk given x and y coordinates.

  Note that these must be chunk coordinates, as they get multiplied by 16
  in the NIF.
  """
  @spec generate_chunk(float, float) :: {:ok, [chunk_section :: binary]} | {:error, any}
  def generate_chunk(_chunk_x, _chunk_z) do
    # Don't use raise here, or Dialyzer complains
    :erlang.nif_error("NIF generate_chunk/2 not implemented")
  end
end
