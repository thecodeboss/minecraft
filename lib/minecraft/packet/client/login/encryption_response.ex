defmodule Minecraft.Packet.Client.Login.EncryptionResponse do
  @moduledoc false
  import Minecraft.Packet, only: [decode_varint: 1, encode_varint: 1]

  @type t :: %__MODULE__{packet_id: 1, shared_secret: binary, verify_token: binary}
  defstruct packet_id: 1,
            shared_secret: nil,
            verify_token: nil

  @spec serialize(t) :: {packet_id :: 1, binary}
  def serialize(%__MODULE__{shared_secret: shared_secret, verify_token: verify_token}) do
    shared_secret_len = encode_varint(byte_size(shared_secret))
    verify_token_len = encode_varint(byte_size(verify_token))

    {1,
     <<shared_secret_len::binary, shared_secret::binary, verify_token_len::binary,
       verify_token::binary>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    {shared_secret_len, rest} = decode_varint(data)
    <<shared_secret::binary-size(shared_secret_len), rest::binary>> = rest
    {verify_token_len, rest} = decode_varint(rest)
    <<verify_token::binary-size(verify_token_len), rest::binary>> = rest
    {%__MODULE__{shared_secret: shared_secret, verify_token: verify_token}, rest}
  end
end
