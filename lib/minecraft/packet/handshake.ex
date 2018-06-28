defmodule Minecraft.Packet.Handshake do
  alias Minecraft.Packet.Client
  alias Minecraft.Protocol
  import Minecraft.Packet
  @protocol_1_12_2 340
  @protocol_1_12_2_v Minecraft.Packet.encode_varint(@protocol_1_12_2)

  @type packet_id :: 0

  @doc """
  Deserializes a handshake packet.
  """
  @spec deserialize(packet_id, binary, type :: :client | :server) ::
          {packet :: term, new_state :: Protocol.state(), rest :: binary}
  def deserialize(0 = _packet_id, <<@protocol_1_12_2_v::binary, rest::binary>>, :client) do
    {server_addr, rest} = decode_string(rest)
    <<server_port::size(16), next_state::size(8), rest::binary>> = rest

    next_state =
      case next_state do
        1 -> :status
        2 -> :login
      end

    packet = %Client.Handshake{
      server_addr: server_addr,
      server_port: server_port,
      next_state: next_state
    }

    {packet, next_state, rest}
  end

  @doc """
  Serializes a handshake packet.
  """
  @spec serialize(packet :: struct) :: binary
  def serialize(%Client.Handshake{} = request) do
    protocol_version = encode_varint(request.protocol_version)
    server_addr = encode_string(request.server_addr)

    next_state =
      case request.next_state do
        :status -> 1
        :login -> 2
      end

    <<protocol_version::binary, server_addr::binary, request.server_port::size(16),
      next_state::size(8)>>
  end
end
