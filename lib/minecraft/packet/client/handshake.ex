defmodule Minecraft.Packet.Client.Handshake do
  @moduledoc false
  import Minecraft.Packet,
    only: [decode_varint: 1, decode_string: 1, encode_varint: 1, encode_string: 1]

  @type t :: %__MODULE__{
          packet_id: 0,
          protocol_version: integer,
          server_addr: String.t(),
          server_port: 1..65535,
          next_state: :status | :login
        }

  defstruct packet_id: 0,
            protocol_version: 340,
            server_addr: nil,
            server_port: nil,
            next_state: nil

  @spec serialize(t) :: {packet_id :: 0, binary}
  def serialize(%__MODULE__{} = packet) do
    protocol_version = encode_varint(packet.protocol_version)
    server_addr = encode_string(packet.server_addr)

    next_state =
      case packet.next_state do
        :status -> 1
        :login -> 2
      end

    {0,
     <<protocol_version::binary, server_addr::binary, packet.server_port::size(16),
       next_state::size(8)>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    {protocol_version, rest} = decode_varint(data)
    {server_addr, rest} = decode_string(rest)
    <<server_port::size(16), next_state::size(8), rest::binary>> = rest

    next_state =
      case next_state do
        1 -> :status
        2 -> :login
      end

    packet = %__MODULE__{
      protocol_version: protocol_version,
      server_addr: server_addr,
      server_port: server_port,
      next_state: next_state
    }

    {packet, rest}
  end
end
