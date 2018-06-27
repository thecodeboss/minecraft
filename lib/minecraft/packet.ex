defmodule Minecraft.Packet do
  alias Minecraft.Packet.Handshake

  @doc """
  Given a raw binary packet, deserializes it into a `Packet` struct.
  """
  def deserialize(data, :handshaking) when is_binary(data) do
    Handshake.deserialize(data)
  end
end
