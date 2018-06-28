defmodule Minecraft.Packet do
  use Bitwise
  alias Minecraft.Packet.Handshake

  @doc """
  Given a raw binary packet, deserializes it into a `Packet` struct.
  """
  @spec deserialize(binary, state :: atom) :: {new_state :: atom, packet :: term}
  def deserialize(data, :handshaking) when is_binary(data) do
    {_packet_size, data} = decode_varint(data)
    {packet_id, data} = decode_varint(data)
    Handshake.deserialize(packet_id, data)
  end

  @doc """
  Decodes a variable-size integer.
  """
  @spec decode_varint(binary) ::
          {decoded :: integer, rest :: binary} | {:error, :too_long | :too_short}
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
          {decoded :: integer, rest :: binary} | {:error, :too_long | :too_short}
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
end
