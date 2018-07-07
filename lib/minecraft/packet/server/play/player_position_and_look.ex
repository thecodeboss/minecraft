defmodule Minecraft.Packet.Server.Play.PlayerPositionAndLook do
  @moduledoc false
  import Minecraft.Packet, only: [decode_varint: 1, encode_varint: 1]

  defstruct packet_id: 0x2F,
            x: 0.0,
            y: 200.0,
            z: 0.0,
            yaw: 0.0,
            pitch: 0.0,
            flags: 0,
            teleport_id: 0

  @type t :: %__MODULE__{
          packet_id: 0x2F,
          x: float,
          y: float,
          z: float,
          yaw: float,
          pitch: float,
          flags: integer,
          teleport_id: integer
        }

  @spec serialize(t) :: {packet_id :: 0x2F, binary}
  def serialize(%__MODULE__{} = packet) do
    {0x2F,
     <<packet.x::64-float, packet.y::64-float, packet.z::64-float, packet.yaw::32-float,
       packet.pitch::32-float, packet.flags::8, encode_varint(packet.teleport_id)::binary>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    <<x::64-float, y::64-float, z::64-float, yaw::32-float, pitch::32-float, flags::8,
      rest::binary>> = data

    {teleport_id, rest} = decode_varint(rest)

    {%__MODULE__{
       x: x,
       y: y,
       z: z,
       yaw: yaw,
       pitch: pitch,
       flags: flags,
       teleport_id: teleport_id
     }, rest}
  end
end
