defmodule Minecraft.Packet.Handshake do
  @protocol_1_12_2 340

  def deserialize(
        <<@protocol_1_12_2::size(16), addr_size::size(8), _server_addr::binary-size(addr_size),
          _port::size(16), 1::size(8)>>
      ) do
    {:status, ""}
  end

  def deserialize(
        <<@protocol_1_12_2::size(16), addr_size::size(8), _server_addr::binary-size(addr_size),
          _port::size(16), 2::size(8)>>
      ) do
    {:login, ""}
  end
end
