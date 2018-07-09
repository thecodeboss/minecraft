defmodule Minecraft.Chunk do
  defstruct [:resource]

  @type t :: %__MODULE__{resource: binary}

  defimpl Inspect do
    @impl true
    def inspect(term, _opts) do
      {:ok, {x, z}} = Minecraft.NIF.get_chunk_coordinates(term.resource)
      "#Chunk<x=#{x}, z=#{z}>"
    end
  end

  def serialize(%__MODULE__{resource: resource} = _chunk) do
    {:ok, data} = Minecraft.NIF.serialize_chunk(resource)
    data
  end

  def num_sections(%__MODULE__{resource: resource} = _chunk) do
    {:ok, num_sections} = Minecraft.NIF.num_chunk_sections(resource)
    num_sections
  end
end
