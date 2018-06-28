defmodule Minecraft.Client do
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
  @spec send(pid, binary) :: {:ok, response :: term} | {:error, term}
  def send(pid, request) when is_binary(request) do
    GenServer.call(pid, {:send, request})
  end

  @impl true
  def init(opts \\ []) do
    port = Keyword.get(opts, :port, 25565)
    tcp_opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', port, tcp_opts)
    {:ok, socket}
  end

  @impl true
  def handle_call({:send, request}, _from, socket) do
    :ok = :gen_tcp.send(socket, request)
    {:ok, response} = :gen_tcp.recv(socket, 0)
    {:reply, response, socket}
  end
end
