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

  def encrypt(pid, secret) do
    GenServer.call(pid, {:encrypt, secret})
  end

  def receive(pid) do
    GenServer.call(pid, :receive)
  end

  @doc """
  Sends a packet to the server.
  """
  @spec send(pid, packet :: struct) :: {:ok, response :: term} | {:error, term}
  def send(pid, packet) do
    GenServer.call(pid, {:send, packet})
  end

  @doc """
  Sends raw data to the server.
  """
  @spec send_raw(pid, data :: binary) :: {:ok, response :: term} | {:error, term}
  def send_raw(pid, data) do
    GenServer.call(pid, {:send_raw, data})
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
    {:ok, {socket, :handshake, nil}}
  end

  @impl true
  def handle_call({:encrypt, secret}, _from, {socket, state, nil}) do
    aes = %Minecraft.Crypto.AES{key: secret, ivec: secret}
    {:reply, :ok, {socket, state, aes}}
  end

  def handle_call(:receive, _from, {socket, state, aes}) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, response} ->
        {response, aes} = maybe_decrypt(response, aes)
        {response_packet, ""} = Minecraft.Packet.deserialize(response, state, :server)
        {:reply, {:ok, response_packet}, {socket, state, aes}}

      {:error, _} = err ->
        {:stop, :normal, err, {socket, state, aes}}
    end
  end

  def handle_call({:send, packet}, _from, {socket, state, aes}) do
    {:ok, request} = Minecraft.Packet.serialize(packet)
    :ok = :gen_tcp.send(socket, request)

    case :gen_tcp.recv(socket, 0) do
      {:ok, response} ->
        {response, aes} = maybe_decrypt(response, aes)
        {response_packet, ""} = Minecraft.Packet.deserialize(response, state, :server)
        {:reply, {:ok, response_packet}, {socket, state, aes}}

      {:error, _} = err ->
        {:stop, :normal, err, {socket, state, aes}}
    end
  end

  @impl true
  def handle_call({:send_raw, data}, _from, {socket, state, aes}) do
    :ok = :gen_tcp.send(socket, data)

    case :gen_tcp.recv(socket, 0) do
      {:ok, response} ->
        {response, aes} = maybe_decrypt(response, aes)
        {response_packet, ""} = Minecraft.Packet.deserialize(response, state, :server)
        {:reply, {:ok, response_packet}, {socket, state, aes}}

      {:error, _} = err ->
        {:stop, :normal, err, {socket, state, aes}}
    end
  end

  def handle_call({:set_state, state}, _from, {socket, _old_state, aes}) do
    {:reply, :ok, {socket, state, aes}}
  end

  @impl true
  def handle_cast({:cast, packet}, {socket, state, aes}) do
    {:ok, request} = Minecraft.Packet.serialize(packet)
    :ok = :gen_tcp.send(socket, request)
    {:noreply, {socket, state, aes}}
  end

  defp maybe_decrypt(data, nil) do
    {data, nil}
  end

  defp maybe_decrypt(data, aes) do
    Minecraft.Crypto.AES.decrypt(data, aes)
  end
end
