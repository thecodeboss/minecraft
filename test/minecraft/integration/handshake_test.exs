defmodule Minecraft.HandshakeTest do
  use ExUnit.Case, async: true
  alias Minecraft.Client
  import Minecraft.Packet

  @protocol_1_12_2 340
  @protocol_1_12_2_v Minecraft.Packet.encode_varint(@protocol_1_12_2)

  setup do
    {:ok, client} = Client.start_link(port: 25565)
    %{client: client}
  end

  test "handshake", %{client: client} do
    server_addr = "localhost"
    port = 25565

    packet =
      build_packet(
        0x00,
        <<@protocol_1_12_2_v::binary, encode_string(server_addr)::binary, port::16-unsigned, 1>>
      )

    assert "Not Implemented" = Client.send(client, packet)
  end

  defp build_packet(packet_id, data) do
    packet_id = encode_varint(packet_id)
    total_size = encode_varint(byte_size(data) + byte_size(packet_id))
    <<total_size::binary, packet_id::binary, data::binary>>
  end
end
