defmodule Minecraft.Packet do
  @moduledoc """
  Base serialization and deserialization routines for packets.
  """
  use Bitwise
  alias Minecraft.Packet.Client
  alias Minecraft.Packet.Server

  @type varint :: -2_147_483_648..2_147_483_647
  @type varlong :: -9_223_372_036_854_775_808..9_223_372_036_854_775_807

  @doc """
  Given a raw binary packet, deserializes it into a `Packet` struct.
  """
  @spec deserialize(binary, state :: atom, type :: :client | :server) ::
          {packet :: term, rest :: binary} | {:error, :invalid_packet}
  def deserialize(data, state, type \\ :client) do
    {_packet_size, data} = decode_varint(data)
    {packet_id, data} = decode_varint(data)

    case {state, packet_id, type} do
      # Client Handshake Packets
      {:handshake, 0, :client} ->
        Client.Handshake.deserialize(data)

      # Client Status Packets
      {:status, 0, :client} ->
        Client.Status.Request.deserialize(data)

      {:status, 1, :client} ->
        Client.Status.Ping.deserialize(data)

      # Server Status Packets
      {:status, 0, :server} ->
        Server.Status.Response.deserialize(data)

      {:status, 1, :server} ->
        Server.Status.Pong.deserialize(data)

      # Client Login Packets
      {:login, 0, :client} ->
        Client.Login.LoginStart.deserialize(data)

      {:login, 1, :client} ->
        Client.Login.EncryptionResponse.deserialize(data)

      # Server Login Packets
      # TODO {:login, 0, :server} ->
      # Server.Login.Disconnect.deserialize(data)

      {:login, 1, :server} ->
        Server.Login.EncryptionRequest.deserialize(data)

      {:login, 2, :server} ->
        Server.Login.LoginSuccess.deserialize(data)

      _ ->
        {:error, :invalid_packet}
    end
  end

  @doc """
  Serializes a packet into binary data.
  """
  @spec serialize(packet :: struct) :: {:ok, binary} | {:error, term}
  def serialize(%struct{} = request) do
    {packet_id, packet_binary} = struct.serialize(request)
    serialize(packet_id, packet_binary)
  end

  @doc """
  Serializes a packet binary into the standard packet format:

  | Field     | Type   | Description                                     |
  | --------- | ------ | ----------------------------------------------- |
  | Length    | VarInt | Length of packet data + length of the packet ID |
  | Packet ID | VarInt |                                                 |
  | Data      | Binary | The serialized packet data                      |
  """
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

  defp decode_varint(<<1::1, value::7, rest::binary>>, num_read, acc) when num_read < 5 do
    decode_varint(rest, num_read + 1, acc + (value <<< (7 * num_read)))
  end

  defp decode_varint(<<0::1, value::7, rest::binary>>, num_read, acc) do
    result = acc + (value <<< (7 * num_read))
    <<result::32-signed>> = <<result::32-unsigned>>
    {result, rest}
  end

  defp decode_varint(_, num_read, _) when num_read >= 5, do: {:error, :too_long}
  defp decode_varint("", _, _), do: {:error, :too_short}

  @doc """
  Decodes a variable-size long.
  """
  @spec decode_varlong(binary) ::
          {decoded :: varlong, rest :: binary} | {:error, :too_long | :too_short}
  def decode_varlong(data) do
    decode_varlong(data, 0, 0)
  end

  defp decode_varlong(<<1::1, value::7, rest::binary>>, num_read, acc) when num_read < 10 do
    decode_varlong(rest, num_read + 1, acc + (value <<< (7 * num_read)))
  end

  defp decode_varlong(<<0::1, value::7, rest::binary>>, num_read, acc) do
    result = acc + (value <<< (7 * num_read))
    <<result::64-signed>> = <<result::64-unsigned>>
    {result, rest}
  end

  defp decode_varlong(_, num_read, _) when num_read >= 10, do: {:error, :too_long}
  defp decode_varlong("", _, _), do: {:error, :too_short}

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

  defp encode_varint(value, _, acc) when value <= 127 do
    <<acc::binary, 0::1, value::7>>
  end

  defp encode_varint(value, num_write, acc) when value > 127 and num_write < 5 do
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
