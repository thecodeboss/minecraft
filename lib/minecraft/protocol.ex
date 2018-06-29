defmodule Minecraft.Protocol do
  @moduledoc """
  A [`:ranch_protocol`](https://ninenines.eu/docs/en/ranch/1.5/guide/protocols/) implementation
  that forwards requests to `Minecraft.Protocol.Handler`.
  """
  use GenServer
  require Logger
  alias Minecraft.Protocol.Handler
  alias Minecraft.Packet

  @behaviour :ranch_protocol

  @typedoc """
  The possible states a client/server can be in.
  """
  @type state :: :handshaking | :status | :login | :play

  defmodule State do
    @moduledoc false
    defstruct [:current, :socket, :transport, :client_ip]
  end

  @impl true
  def start_link(ref, socket, transport, protocol_opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [{ref, socket, transport, protocol_opts}])
    {:ok, pid}
  end

  @impl true
  def init({ref, socket, transport, _protocol_opts}) do
    :ok = :ranch.accept_ack(ref)
    {:ok, {client_ip, _port}} = :inet.peername(socket)
    client_ip = :inet.ntoa(client_ip)

    state = %State{
      current: :handshaking,
      socket: socket,
      transport: transport,
      client_ip: client_ip
    }

    :ok = transport.setopts(socket, active: :once)
    Logger.info(fn -> "Client #{client_ip} connected." end)
    :gen_server.enter_loop(__MODULE__, [], state)
  end

  @impl true
  def handle_info({:tcp, socket, packet}, state) do
    {packet, current, rest} = Packet.deserialize(packet, state.current)
    Logger.debug(fn -> "REQUEST: #{inspect(packet)}" end)

    if byte_size(rest) > 0 do
      send(self(), {:tcp, socket, rest})
    end

    case Handler.handle(packet) do
      {:ok, :noreply} ->
        :ok = state.transport.setopts(socket, active: :once)
        {:noreply, %State{state | current: current}}

      {:ok, response_packet} ->
        Logger.debug(fn -> "RESPONSE: #{inspect(response_packet)}" end)
        {:ok, response} = Packet.serialize(response_packet)
        :ok = state.transport.setopts(socket, active: :once)
        :ok = state.transport.send(socket, response)
        {:noreply, %State{state | current: current}}

      err ->
        Logger.error(fn -> "#{__MODULE__} error: #{inspect(err)}" end)
        :ok = state.transport.close(socket)
        {:stop, :normal, state}
    end
  end

  def handle_info({:tcp_closed, socket}, state) do
    Logger.info(fn -> "Client #{state.client_ip} disconnected." end)
    :ok = state.transport.close(socket)
    {:stop, :normal, state}
  end
end
