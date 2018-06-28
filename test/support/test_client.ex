defmodule Minecraft.TestClient do
  @moduledoc """
  A client for connecting to the Minecraft server. Note that this is only compiled in the test
  environment as this is the only place it should be used.
  """
  use GenServer

  @type client_opt :: {:port, 0..65535}
  @type client_opts :: [client_opt]

  @doc """
  Starts the client.
  """
  @spec start_link(client_opts) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [opts])
  end

  @doc """
  Sends a message to the server.
  """
  @spec send(pid, struct) :: {:ok, response :: term} | {:error, term}
  def send(pid, packet) do
    GenServer.call(pid, {:send, packet})
  end

  @doc """
  Sets the client's connection state.
  """
  @spec set_state(pid, struct) :: :ok | {:error, term}
  def set_state(pid, state) do
    GenServer.call(pid, {:set_state, state})
  end

  @doc """
  Sends a message to the server without waiting for a response.
  """
  @spec cast(pid, struct) :: :ok | {:error, term}
  def cast(pid, packet) do
    GenServer.cast(pid, {:cast, packet})
  end

  @impl true
  def init(opts \\ []) do
    port = Keyword.get(opts, :port, 25565)
    tcp_opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', port, tcp_opts)
    {:ok, {socket, :handshaking}}
  end

  @impl true
  def handle_call({:send, packet}, _from, {socket, state}) do
    {:ok, request} = Minecraft.Packet.serialize(packet)
    :ok = :gen_tcp.send(socket, request)
    {:ok, response} = :gen_tcp.recv(socket, 0)
    {response_packet, _, ""} = Minecraft.Packet.deserialize(response, state, :server)
    {:reply, {:ok, response_packet}, {socket, state}}
  end

  def handle_call({:set_state, state}, _from, {socket, _old_state}) do
    {:reply, :ok, {socket, state}}
  end

  @impl true
  def handle_cast({:cast, packet}, {socket, state}) do
    {:ok, request} = Minecraft.Packet.serialize(packet)
    :ok = :gen_tcp.send(socket, request)
    {:noreply, {socket, state}}
  end
end
