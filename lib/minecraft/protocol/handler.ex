defmodule Minecraft.Protocol.Handler do
  alias Minecraft.Packet.Client
  alias Minecraft.Packet.Server

  @spec handle(struct) :: {:ok, :noreply | struct} | {:error, :unknown_packet}
  def handle(%Client.Handshake{}) do
    {:ok, :noreply}
  end

  def handle(%Client.Status.Request{}) do
    {:ok, json} =
      Poison.encode(%{
        version: %{name: "1.12.2", protocol: 340},
        players: %{max: 20, online: 0, sample: []},
        description: %{text: "Elixir Minecraft"}
      })

    {:ok, %Server.Status.Response{json: json}}
  end

  def handle(%Client.Status.Ping{payload: payload}) do
    {:ok, %Server.Status.Pong{payload: payload}}
  end

  def handle(_packet) do
    {:error, :unknown_packet}
  end
end
