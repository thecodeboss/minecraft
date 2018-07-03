defmodule Minecraft.Packet.Client.Play.PluginMessage do
  @moduledoc false
  import Minecraft.Packet, only: [encode_string: 1, decode_string: 1]
  @type t :: %__MODULE__{packet_id: 9, channel: String.t(), data: binary}
  defstruct packet_id: 9,
            channel: nil,
            data: nil

  @spec serialize(t) :: {packet_id :: 9, binary}
  def serialize(%__MODULE__{channel: channel, data: data} = _packet) do
    {9, <<encode_string(channel)::binary, data::binary>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    {channel, rest} = decode_string(data)

    {%__MODULE__{channel: channel, data: rest}, ""}
  end
end
