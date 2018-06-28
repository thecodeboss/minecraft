defmodule Minecraft.Packet.Handshake do
  alias Minecraft.Protocol
  @protocol_1_12_2 340
  @protocol_1_12_2_v Minecraft.Packet.encode_varint(@protocol_1_12_2)

  @type packet_id :: 0

  @doc """
  Deserializes a handshake packet.
  """
  @spec deserialize(packet_id, binary) :: {new_state :: Protocol.state(), packet :: term}
  def deserialize(
        0 = _packet_id,
        <<@protocol_1_12_2_v::binary, addr_size::size(8), _server_addr::binary-size(addr_size),
          _port::size(16), 1::size(8)>>
      ) do
    {:status, ""}
  end

  def deserialize(
        0 = _packet_id,
        <<@protocol_1_12_2_v::binary, addr_size::size(8), _server_addr::binary-size(addr_size),
          _port::size(16), 2::size(8)>>
      ) do
    {:login, ""}
  end
end
