defmodule Minecraft.Packet.Server.Login.LoginSuccess do
  @moduledoc false
  import Minecraft.Packet, only: [decode_string: 1, encode_string: 1]

  @type t :: %__MODULE__{
          packet_id: 2,
          uuid: String.t(),
          username: String.t()
        }

  defstruct packet_id: 2,
            uuid: nil,
            username: nil

  @spec serialize(t) :: {packet_id :: 2, binary}
  def serialize(%__MODULE__{uuid: uuid, username: username}) do
    {2, <<encode_string(uuid)::binary, encode_string(username)::binary>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    {uuid, rest} = decode_string(data)
    {username, rest} = decode_string(rest)
    {%__MODULE__{uuid: uuid, username: username}, rest}
  end
end
