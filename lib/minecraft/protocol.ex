defmodule Minecraft.Protocol do
  @moduledoc """
  A ranch protocol implementation that forwards requests to the protocol
  handler module.
  """
  use GenServer
  require Logger
  alias Minecraft.Protocol.{Handler, Request}

  @behaviour :ranch_protocol

  defmodule State do
    defstruct socket: nil, transport: nil
  end

  @impl true
  def start_link(ref, socket, transport, protocol_opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [{ref, socket, transport, protocol_opts}])
    {:ok, pid}
  end

  @impl true
  def init({ref, socket, transport, _protocol_opts}) do
    state = %State{socket: socket, transport: transport}

    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, active: :once)
    :gen_server.enter_loop(__MODULE__, [], state)
  end

  @impl true
  def handle_info({:tcp, socket, packet}, %State{transport: transport} = state) do
    {:ok, request} = Request.deserialize(packet)
    {:ok, response} = Handler.handle(request)
    :ok = transport.setopts(socket, active: :once)
    :ok = transport.send(socket, response)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, %State{transport: transport} = state) do
    Logger.info(fn -> "Client disconnected." end)
    :ok = transport.close(socket)
    {:stop, :normal, state}
  end
end
