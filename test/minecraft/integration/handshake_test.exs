defmodule Minecraft.HandshakeTest do
  use ExUnit.Case, async: true
  alias Minecraft.Client

  @protocol_1_12_2 <<0xD4, 0x02>>

  setup do
    {:ok, client} = Client.start_link(port: 25565)
    %{client: client}
  end

  test "handshake", %{client: client} do
    server_addr = "127.0.0.1"
    port = 25565

    packet =
      build_packet(
        0x00,
        <<@protocol_1_12_2::binary, byte_size(server_addr), server_addr::binary,
          port::16-unsigned, 1>>
      )

    assert "Not Implemented" = Client.send(client, packet)
  end

  defp build_packet(packet_id, data) do
    # TODO: Handle varint encoding properly
    total_size = byte_size(data) + 8
    <<total_size::8, packet_id::8, data::binary>>
  end
end
