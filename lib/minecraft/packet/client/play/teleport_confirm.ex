defmodule Minecraft.Packet.Client.Play.TeleportConfirm do
  @moduledoc false
  import Minecraft.Packet, only: [encode_varint: 1, decode_varint: 1]
  @type t :: %__MODULE__{packet_id: 0, teleport_id: integer}
  defstruct packet_id: 0,
            teleport_id: nil

  @spec serialize(t) :: {packet_id :: 0, binary}
  def serialize(%__MODULE__{teleport_id: teleport_id} = _packet) do
    {0, <<encode_varint(teleport_id)::binary>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    {teleport_id, rest} = decode_varint(data)

    {%__MODULE__{teleport_id: teleport_id}, rest}
  end
end
