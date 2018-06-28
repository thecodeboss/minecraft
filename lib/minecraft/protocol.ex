defmodule Minecraft.Protocol do
  @moduledoc """
  A ranch protocol implementation that forwards requests to the protocol
  handler module.
  """
  use GenServer
  require Logger
  alias Minecraft.Protocol.Handler
  alias Minecraft.Packet

  @behaviour :ranch_protocol
  @type state :: :handshaking | :status | :login | :play

  defmodule State do
    defstruct [:current, :socket, :transport]
  end

  @impl true
  def start_link(ref, socket, transport, protocol_opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [{ref, socket, transport, protocol_opts}])
    {:ok, pid}
  end

  @impl true
  def init({ref, socket, transport, _protocol_opts}) do
    state = %State{current: :handshaking, socket: socket, transport: transport}

    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, active: :once)
    :gen_server.enter_loop(__MODULE__, [], state)
  end

  @impl true
  def handle_info({:tcp, socket, packet}, state) do
    {current, packet} = Packet.deserialize(packet, state.current)
    {:ok, response} = Handler.handle(packet)
    :ok = state.transport.setopts(socket, active: :once)
    :ok = state.transport.send(socket, response)
    {:noreply, %State{state | current: current}}
  end

  def handle_info({:tcp_closed, socket}, state) do
    Logger.info(fn -> "Client disconnected." end)
    :ok = state.transport.close(socket)
    {:stop, :normal, state}
  end
end
