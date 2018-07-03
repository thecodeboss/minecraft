defmodule Minecraft.Packet.Client.Login.LoginStart do
  @moduledoc false
  import Minecraft.Packet, only: [decode_string: 1, encode_string: 1]
  @type t :: %__MODULE__{packet_id: 0, username: String.t()}
  defstruct packet_id: 0,
            username: nil

  @spec serialize(t) :: {packet_id :: 0, binary}
  def serialize(%__MODULE__{username: username}) do
    {0, encode_string(username)}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    {username, rest} = decode_string(data)
    {%__MODULE__{username: username}, rest}
  end
end
