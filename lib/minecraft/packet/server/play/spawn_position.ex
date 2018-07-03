defmodule Minecraft.Packet.Server.Play.SpawnPosition do
  @moduledoc false
  import Minecraft.Packet, only: [decode_position: 1, encode_position: 1]

  defstruct packet_id: 0x46,
            position: nil

  @type t :: %__MODULE__{packet_id: 0x46, position: Minecraft.Packet.position()}

  @spec serialize(t) :: {packet_id :: 0x46, binary}
  def serialize(%__MODULE__{position: position}) do
    {0x46, encode_position(position)}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    {position, rest} = decode_position(data)
    {%__MODULE__{position: position}, rest}
  end
end
