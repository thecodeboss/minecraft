defmodule Minecraft.HandshakeTest do
  use ExUnit.Case, async: true
  alias Minecraft.Packet.Client
  alias Minecraft.Packet.Server
  alias Minecraft.TestClient

  setup do
    {:ok, client} = TestClient.start_link(port: 25565)
    %{client: client}
  end

  test "handshake", %{client: client} do
    packet = %Client.Handshake{server_addr: "localhost", server_port: 25565, next_state: :status}
    assert :ok = TestClient.cast(client, packet)
    assert :ok = TestClient.set_state(client, :status)

    assert {:ok, %Server.Status.Response{} = response} =
             TestClient.send(client, %Client.Status.Request{})

    assert Poison.decode!(response.json) == %{
             "version" => %{"name" => "1.12.2", "protocol" => 340},
             "players" => %{"max" => 20, "online" => 0, "sample" => []},
             "description" => %{"text" => "Elixir Minecraft"}
           }

    assert {:ok, %Server.Status.Pong{payload: 12_345_678}} =
             TestClient.send(client, %Client.Status.Ping{payload: 12_345_678})
  end
end
