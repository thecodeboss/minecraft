defmodule Minecraft.Protocol.Handler do
  @moduledoc """
  Server-side handler for responding to client packets.
  """
  alias Minecraft.Connection
  alias Minecraft.Crypto
  alias Minecraft.Packet.Client
  alias Minecraft.Packet.Server

  @doc """
  Handles a packet from a client, and returns either a response packet, or `{:ok, :noreply}`.
  """
  @spec handle(packet :: struct, Connection.t()) ::
          {:ok, :noreply | struct, Connection.t()}
          | {:error, :unsupported_protocol, Connection.t()}
  def handle(%Client.Handshake{protocol_version: 340} = packet, conn) do
    conn =
      conn
      |> Connection.put_state(packet.next_state)
      |> Connection.put_protocol(340)
      |> Connection.assign(:server_addr, packet.server_addr)

    {:ok, :noreply, conn}
  end

  def handle(%Client.Handshake{protocol_version: _}, conn) do
    {:error, :unsupported_protocol, conn}
  end

  def handle(%Client.Status.Request{}, conn) do
    {:ok, json} =
      Poison.encode(%{
        version: %{name: "1.12.2", protocol: 340},
        players: %{max: 20, online: 0, sample: []},
        description: %{text: "Elixir Minecraft"}
      })

    {:ok, %Server.Status.Response{json: json}, conn}
  end

  def handle(%Client.Status.Ping{payload: payload}, conn) do
    {:ok, %Server.Status.Pong{payload: payload}, conn}
  end

  def handle(%Client.Login.LoginStart{username: username}, conn) do
    verify_token = :crypto.strong_rand_bytes(4)

    conn =
      conn
      |> Connection.assign(:username, username)
      |> Connection.assign(:verify_token, verify_token)

    response = %Server.Login.EncryptionRequest{
      server_id: "",
      public_key: Crypto.get_public_key(),
      verify_token: verify_token
    }

    {:ok, response, conn}
  end

  def handle(%Client.Login.EncryptionResponse{} = packet, conn) do
    verify_token = Crypto.decrypt(packet.verify_token)

    case conn.assigns[:verify_token] do
      ^verify_token ->
        shared_secret = Crypto.decrypt(packet.shared_secret)

        conn =
          conn
          |> Connection.encrypt(shared_secret)
          |> Connection.verify_login()

        response = %Server.Login.LoginSuccess{
          uuid: conn.assigns[:uuid],
          username: conn.assigns[:username]
        }

        {:ok, response, conn}

      _ ->
        {:error, :bad_verify_token, conn}
    end
  end
end
