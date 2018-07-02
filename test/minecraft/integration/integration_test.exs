defmodule Minecraft.HandshakeTest do
  use ExUnit.Case, async: true
  alias Minecraft.Packet.Client
  alias Minecraft.Packet.Server
  alias Minecraft.TestClient

  import Mock

  @fake_mojang_response %HTTPoison.Response{
    body: ~S({"id": "f7fa50bd53384a68a9e5a601e24cdf8e", "name": "TheCodeBoss"}),
    status_code: 200
  }

  setup do
    {:ok, client} = TestClient.start_link(port: 25565)
    %{client: client}
  end

  test "status", %{client: client} do
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

  test "login and play", %{client: client} do
    with_mock HTTPoison, get!: fn _url -> @fake_mojang_response end do
      packet = %Client.Handshake{server_addr: "localhost", server_port: 25565, next_state: :login}
      assert :ok = TestClient.cast(client, packet)
      assert :ok = TestClient.set_state(client, :login)

      assert {:ok, %Server.Login.EncryptionRequest{} = encryption_request} =
               TestClient.send(client, %Client.Login.LoginStart{username: "TheCodeBoss"})

      shared_secret = :crypto.strong_rand_bytes(16)

      encryption_response = %Client.Login.EncryptionResponse{
        shared_secret: Minecraft.Crypto.encrypt(shared_secret),
        verify_token: Minecraft.Crypto.encrypt(encryption_request.verify_token)
      }

      assert :ok = TestClient.cast(client, encryption_response)
      :ok = TestClient.encrypt(client, shared_secret)

      assert {:ok, %Server.Login.LoginSuccess{username: "TheCodeBoss"}} =
               TestClient.receive(client)

      assert :ok = TestClient.set_state(client, :play)
      assert :ok = TestClient.cast(client, %Client.Play.ClientSettings{})

      assert :ok =
               TestClient.cast(client, %Client.Play.PluginMessage{
                 channel: "MC|Brand",
                 data: "\avanilla"
               })

      assert {:ok, %Server.Play.JoinGame{}} = TestClient.receive(client)
      assert {:ok, %Server.Play.SpawnPosition{}} = TestClient.receive(client)
      assert {:ok, %Server.Play.PlayerAbilities{}} = TestClient.receive(client)
    end
  end

  test "invalid protocol", %{client: client} do
    packet = %Client.Handshake{
      protocol_version: 123,
      server_addr: "localhost",
      server_port: 25565,
      next_state: :status
    }

    assert {:error, :closed} = TestClient.send(client, packet)
  end

  test "invalid packet results in socket closure", %{client: client} do
    assert {:error, :closed} = TestClient.send_raw(client, <<1, 2, 3>>)
  end

  test "invalid verify token", %{client: client} do
    packet = %Client.Handshake{server_addr: "localhost", server_port: 25565, next_state: :login}
    assert :ok = TestClient.cast(client, packet)
    assert :ok = TestClient.set_state(client, :login)

    assert {:ok, %Server.Login.EncryptionRequest{}} =
             TestClient.send(client, %Client.Login.LoginStart{username: "TheCodeBoss"})

    shared_secret = :crypto.strong_rand_bytes(16)

    encryption_response = %Client.Login.EncryptionResponse{
      shared_secret: Minecraft.Crypto.encrypt(shared_secret),
      verify_token: Minecraft.Crypto.encrypt(<<1, 2, 3, 4>>)
    }

    assert {:error, :closed} = TestClient.send(client, encryption_response)
  end
end
