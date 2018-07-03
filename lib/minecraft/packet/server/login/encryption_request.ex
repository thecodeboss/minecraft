defmodule Minecraft.Packet.Server.Login.EncryptionRequest do
  @moduledoc false
  import Minecraft.Packet,
    only: [decode_string: 1, decode_varint: 1, encode_string: 1, encode_varint: 1]

  @type t :: %__MODULE__{
          packet_id: 1,
          server_id: String.t(),
          public_key: binary,
          verify_token: binary
        }

  defstruct packet_id: 1,
            server_id: nil,
            public_key: nil,
            verify_token: nil

  @spec serialize(t) :: {packet_id :: 1, binary}
  def serialize(%__MODULE__{} = packet) do
    public_key_len = encode_varint(byte_size(packet.public_key))
    verify_token_len = encode_varint(byte_size(packet.verify_token))

    {1,
     <<encode_string(packet.server_id)::binary, public_key_len::binary, packet.public_key::binary,
       verify_token_len::binary, packet.verify_token::binary>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    {server_id, rest} = decode_string(data)
    {public_key_len, rest} = decode_varint(rest)
    <<public_key::binary-size(public_key_len), rest::binary>> = rest
    {verify_token_len, rest} = decode_varint(rest)
    <<verify_token::binary-size(verify_token_len), rest::binary>> = rest

    {%__MODULE__{server_id: server_id, public_key: public_key, verify_token: verify_token}, rest}
  end
end
