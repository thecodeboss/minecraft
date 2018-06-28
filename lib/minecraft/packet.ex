defmodule Minecraft.Packet do
  use Bitwise
  alias Minecraft.Packet.Client
  alias Minecraft.Packet.Handshake
  alias Minecraft.Packet.Server
  alias Minecraft.Packet.Status

  @type varint :: -2_147_483_648..2_147_483_647
  @type varlong :: -9_223_372_036_854_775_808..9_223_372_036_854_775_807

  @doc """
  Given a raw binary packet, deserializes it into a `Packet` struct.
  """
  @spec deserialize(binary, state :: atom, type :: :client | :server) ::
          {packet :: term, new_state :: atom, rest :: binary}
  def deserialize(data, state, type \\ :client)

  def deserialize(data, :handshaking, type) when is_binary(data) do
    {_packet_size, data} = decode_varint(data)
    {packet_id, data} = decode_varint(data)
    Handshake.deserialize(packet_id, data, type)
  end

  def deserialize(data, :status, type) when is_binary(data) do
    {_packet_size, data} = decode_varint(data)
    {packet_id, data} = decode_varint(data)
    Status.deserialize(packet_id, data, type)
  end

  @spec serialize(response :: struct) :: {:ok, binary} | {:error, term}
  def serialize(%Client.Handshake{} = request) do
    packet_binary = Handshake.serialize(request)
    serialize(request.packet_id, packet_binary)
  end

  def serialize(%Client.Status.Request{} = request) do
    packet_binary = Status.serialize(request)
    serialize(request.packet_id, packet_binary)
  end

  def serialize(%Client.Status.Ping{} = request) do
    packet_binary = Status.serialize(request)
    serialize(request.packet_id, packet_binary)
  end

  def serialize(%Server.Status.Response{} = response) do
    packet_binary = Status.serialize(response)
    serialize(response.packet_id, packet_binary)
  end

  def serialize(%Server.Status.Pong{} = response) do
    packet_binary = Status.serialize(response)
    serialize(response.packet_id, packet_binary)
  end

  @spec serialize(packet_id :: integer, binary) :: {:ok, binary} | {:error, term}
  def serialize(packet_id, packet_binary) do
    packet_id = encode_varint(packet_id)
    packet_size = encode_varint(byte_size(packet_binary) + byte_size(packet_id))
    response = <<packet_size::binary, packet_id::binary, packet_binary::binary>>
    {:ok, response}
  end

  @doc """
  Decodes a variable-size integer.
  """
  @spec decode_varint(binary) ::
          {decoded :: varint, rest :: binary} | {:error, :too_long | :too_short}
  def decode_varint(data) do
    decode_varint(data, 0, 0)
  end

  def decode_varint(<<1::1, value::7, rest::binary>>, num_read, acc) when num_read < 5 do
    decode_varint(rest, num_read + 1, acc + (value <<< (7 * num_read)))
  end

  def decode_varint(<<0::1, value::7, rest::binary>>, num_read, acc) do
    result = acc + (value <<< (7 * num_read))
    <<result::32-signed>> = <<result::32-unsigned>>
    {result, rest}
  end

  def decode_varint(_, num_read, _) when num_read >= 5, do: {:error, :too_long}
  def decode_varint("", _, _), do: {:error, :too_short}

  @doc """
  Decodes a variable-size long.
  """
  @spec decode_varlong(binary) ::
          {decoded :: varlong, rest :: binary} | {:error, :too_long | :too_short}
  def decode_varlong(data) do
    decode_varlong(data, 0, 0)
  end

  def decode_varlong(<<1::1, value::7, rest::binary>>, num_read, acc) when num_read < 10 do
    decode_varlong(rest, num_read + 1, acc + (value <<< (7 * num_read)))
  end

  def decode_varlong(<<0::1, value::7, rest::binary>>, num_read, acc) do
    result = acc + (value <<< (7 * num_read))
    <<result::64-signed>> = <<result::64-unsigned>>
    {result, rest}
  end

  def decode_varlong(_, num_read, _) when num_read >= 10, do: {:error, :too_long}
  def decode_varlong("", _, _), do: {:error, :too_short}

  @doc """
  Decodes a string.
  """
  @spec decode_string(binary) :: {decoded :: binary, rest :: binary}
  def decode_string(data) do
    {strlen, data} = decode_varint(data)
    <<string::binary-size(strlen), rest::binary>> = data
    {string, rest}
  end

  @doc """
  Encodes a variable-size integer.
  """
  @spec encode_varint(varint) :: binary | {:error, :too_large}
  def encode_varint(value) when value in -2_147_483_648..2_147_483_647 do
    <<value::32-unsigned>> = <<value::32-signed>>
    encode_varint(value, 0, "")
  end

  def encode_varint(_) do
    {:error, :too_large}
  end

  def encode_varint(value, _, acc) when value <= 127 do
    <<acc::binary, 0::1, value::7>>
  end

  def encode_varint(value, num_write, acc) when value > 127 and num_write < 5 do
    encode_varint(value >>> 7, num_write + 1, <<acc::binary, 1::1, band(value, 0x7F)::7>>)
  end

  @doc """
  Encodes a string.
  """
  @spec encode_string(binary) :: binary
  def encode_string(string) do
    strlen = encode_varint(byte_size(string))
    <<strlen::binary, string::binary>>
  end
end
