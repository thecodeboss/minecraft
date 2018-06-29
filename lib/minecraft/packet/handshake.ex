defmodule Minecraft.Packet.Handshake do
  @moduledoc """
  Serialization and deserialization routines for handshake packets.
  """
  alias Minecraft.Packet.Client
  import Minecraft.Packet

  @type packet_id :: 0

  @doc """
  Deserializes a handshake packet.
  """
  @spec deserialize(packet_id, binary, type :: :client | :server) ::
          {packet :: term, rest :: binary} | {:error, :invalid_packet}
  def deserialize(0 = _packet_id, data, :client = _type) do
    {protocol_version, rest} = decode_varint(data)
    {server_addr, rest} = decode_string(rest)
    <<server_port::size(16), next_state::size(8), rest::binary>> = rest

    next_state =
      case next_state do
        1 -> :status
        2 -> :login
      end

    packet = %Client.Handshake{
      protocol_version: protocol_version,
      server_addr: server_addr,
      server_port: server_port,
      next_state: next_state
    }

    {packet, rest}
  end

  def deserialize(_, _, _) do
    {:error, :invalid_packet}
  end

  @doc """
  Serializes a handshake packet.
  """
  @spec serialize(packet :: struct) :: binary
  def serialize(%Client.Handshake{} = packet) do
    protocol_version = encode_varint(packet.protocol_version)
    server_addr = encode_string(packet.server_addr)

    next_state =
      case packet.next_state do
        :status -> 1
        :login -> 2
      end

    <<protocol_version::binary, server_addr::binary, packet.server_port::size(16),
      next_state::size(8)>>
  end
end
