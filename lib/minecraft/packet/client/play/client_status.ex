defmodule Minecraft.Packet.Client.Play.ClientStatus do
  @moduledoc false
  import Minecraft.Packet, only: [encode_varint: 1, decode_varint: 1]
  @type t :: %__MODULE__{packet_id: 3, action: :perform_respawn | :request_stats}
  defstruct packet_id: 3,
            action: :perform_respawn

  @spec serialize(t) :: {packet_id :: 3, binary}
  def serialize(%__MODULE__{action: action} = _packet) do
    action = if action == :perform_respawn, do: 0, else: 1
    {3, <<encode_varint(action)::binary>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    {action, rest} = decode_varint(data)

    action = if action == 0, do: :perform_respawn, else: :request_stats

    {%__MODULE__{action: action}, rest}
  end
end
