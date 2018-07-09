defmodule Minecraft.Protocol do
  @moduledoc """
  A [`:ranch_protocol`](https://ninenines.eu/docs/en/ranch/1.5/guide/protocols/) implementation
  that forwards requests to `Minecraft.Protocol.Handler`.
  """
  use GenServer
  require Logger
  alias Minecraft.Connection
  alias Minecraft.Protocol.Handler

  @behaviour :ranch_protocol

  @impl true
  def start_link(ref, socket, transport, protocol_opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [{ref, socket, transport, protocol_opts}])
    {:ok, pid}
  end

  @doc """
  Sends a packet to the connected client.
  """
  @spec send_packet(pid, struct) :: :ok | {:error, term}
  def send_packet(pid, packet) do
    GenServer.call(pid, {:send_packet, packet})
  end

  def get_conn(pid) do
    GenServer.call(pid, :get_conn)
  end

  #
  # Server Callbacks
  #

  @impl true
  def init({ref, socket, transport, _protocol_opts}) do
    :ok = :ranch.accept_ack(ref)
    conn = Connection.init(self(), socket, transport)
    :gen_server.enter_loop(__MODULE__, [], conn)
  end

  @impl true
  def handle_info({:tcp, socket, data}, conn) do
    conn
    |> Connection.put_socket(socket)
    |> Connection.put_data(data)
    |> handle_conn()
  end

  def handle_info({:tcp_closed, socket}, conn) do
    Logger.info(fn -> "Client #{conn.client_ip} disconnected." end)
    :ok = conn.transport.close(socket)
    {:stop, :normal, conn}
  end

  @impl true
  def handle_call({:send_packet, packet}, _from, conn) do
    conn = Connection.send_packet(conn, packet)
    {:reply, :ok, conn}
  end

  def handle_call(:get_conn, _from, conn) do
    {:reply, conn, conn}
  end

  #
  # Helpers
  #
  defp handle_conn(%Connection{join: true, state_machine: nil} = conn) do
    {:ok, state_machine} = Minecraft.StateMachine.start_link(self())
    handle_conn(%Connection{conn | state_machine: state_machine})
  end

  defp handle_conn(%Connection{data: ""} = conn) do
    conn = Connection.continue(conn)
    {:noreply, conn}
  end

  defp handle_conn(%Connection{} = conn) do
    case Connection.read_packet(conn) do
      {:ok, packet, conn} ->
        handle_packet(packet, conn)

      {:error, conn} ->
        conn = Connection.close(conn)
        {:stop, :normal, conn}
    end
  end

  defp handle_packet(packet, conn) do
    case Handler.handle(packet, conn) do
      {:ok, :noreply, conn} ->
        handle_conn(conn)

      {:ok, response, conn} ->
        conn
        |> Connection.send_packet(response)
        |> handle_conn()

      {:error, _, conn} = err ->
        Logger.error(fn -> "#{__MODULE__} error: #{inspect(err)}" end)
        conn = Connection.close(conn)
        {:stop, :normal, conn}
    end
  end
end
