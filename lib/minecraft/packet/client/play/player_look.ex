defmodule Minecraft.Packet.Client.Play.PlayerLook do
  @moduledoc false
  import Minecraft.Packet, only: [decode_bool: 1, encode_bool: 1]

  defstruct packet_id: 0x0F,
            yaw: 0.0,
            pitch: 0.0,
            on_ground: true

  @type t :: %__MODULE__{
          packet_id: 0x0F,
          yaw: float,
          pitch: float,
          on_ground: boolean
        }

  @spec serialize(t) :: {packet_id :: 0x0F, binary}
  def serialize(%__MODULE__{} = packet) do
    {0x0F,
     <<packet.yaw::32-float, packet.pitch::32-float, encode_bool(packet.on_ground)::binary>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    <<yaw::32-float, pitch::32-float, rest::binary>> = data

    {on_ground, rest} = decode_bool(rest)

    {%__MODULE__{
       yaw: yaw,
       pitch: pitch,
       on_ground: on_ground
     }, rest}
  end
end
