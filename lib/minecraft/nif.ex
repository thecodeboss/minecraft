defmodule Minecraft.NIF do
  @moduledoc """
  NIFs for dealing with chunks.
  """
  @on_load :load_nifs

  @doc false
  @spec load_nifs() :: :ok | {:error, any}
  def load_nifs() do
    :ok = :erlang.load_nif('./priv/nifs', 0)
  end

  @doc """
  Sets the random seed used for world generation.
  """
  @spec set_random_seed(integer) :: :ok
  def set_random_seed(_seed) do
    # Don't raise here, or Dialyzer complains
    :erlang.nif_error("NIF set_random_seed/1 not implemented")
  end

  @doc """
  Generates a chunk given x and y coordinates.

  Note that these must be chunk coordinates, as they get multiplied by 16
  in the NIF.
  """
  @spec generate_chunk(float, float) :: {:ok, any} | {:error, any}
  def generate_chunk(_chunk_x, _chunk_z) do
    # Don't raise here, or Dialyzer complains
    :erlang.nif_error("NIF generate_chunk/2 not implemented")
  end

  @doc """
  Serializes a Chunk.
  """
  @spec serialize_chunk(any) :: {:ok, any} | {:error, any}
  def serialize_chunk(_chunk) do
    # Don't raise here, or Dialyzer complains
    :erlang.nif_error("NIF serialize_chunk/1 not implemented")
  end

  @doc """
  Gets coordinates of a chunk.
  """
  @spec get_chunk_coordinates(any) :: {:ok, {integer, integer}} | :error
  def get_chunk_coordinates(_chunk) do
    # Don't raise here, or Dialyzer complains
    :erlang.nif_error("NIF get_chunk_coordinates/1 not implemented")
  end

  @doc """
  Gets the number of chunk sections in a chunk.
  """
  @spec num_chunk_sections(any) :: {:ok, integer} | :error
  def num_chunk_sections(_chunk) do
    # Don't raise here, or Dialyzer complains
    :erlang.nif_error("NIF num_chunk_sections/1 not implemented")
  end

  @doc """
  Gets the biome data for a chunk.
  """
  @spec chunk_biome_data(any) :: {:ok, binary} | :error
  def chunk_biome_data(_chunk) do
    # Don't raise here, or Dialyzer complains
    :erlang.nif_error("NIF chunk_biome_data/1 not implemented")
  end
end
