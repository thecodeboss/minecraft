defmodule Minecraft.Packet.Server.Status.Response do
  @moduledoc false
  import Minecraft.Packet, only: [decode_string: 1, encode_string: 1]

  @type t :: %__MODULE__{packet_id: 0, json: String.t()}

  defstruct packet_id: 0,
            json: nil

  @spec serialize(t) :: {packet_id :: 0, binary}
  def serialize(%__MODULE__{json: json}) do
    {0, encode_string(json)}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    {json, rest} = decode_string(data)
    {%__MODULE__{json: json}, rest}
  end
end
