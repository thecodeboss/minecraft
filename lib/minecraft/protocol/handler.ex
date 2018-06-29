defmodule Minecraft.Protocol.Handler do
  @moduledoc """
  Server-side handler for responding to client packets.
  """
  alias Minecraft.Connection
  alias Minecraft.Packet.Client
  alias Minecraft.Packet.Server

  @doc """
  Handles a packet from a client, and returns either a response packet, or `{:ok, :noreply}`.
  """
  @spec handle(packet :: struct, Connection.t()) ::
          {:ok, :noreply | struct, Connection.t()}
          | {:error, :unsupported_protocol, Connection.t()}
  def handle(%Client.Handshake{protocol_version: 340, next_state: next_state} = _packet, conn) do
    conn =
      conn
      |> Connection.put_state(next_state)
      |> Connection.put_protocol(340)

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
end
