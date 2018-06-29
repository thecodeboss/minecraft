defmodule Minecraft.Server do
  @moduledoc """
  The core Minecraft server that listens on a TCP port.
  """

  @type server_opt :: {:max_connections, non_neg_integer()} | {:port, 0..65535}
  @type server_opts :: [server_opt]

  @doc """
  Returns a specification to start this module under a supervisor. See `Supervisor` for
  more information.

  Valid options are:
    * `:max_connections` - The maximum number of connections this server can handle. Default
      is 100.
    * `:port` - Which port to start the server on. Default is 25565.
  """
  @spec child_spec(server_opts) :: Supervisor.child_spec()
  def child_spec(opts \\ []) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  @doc """
  Starts the server.
  """
  @spec start_link(server_opts) :: {:ok, pid()} | {:error, term()}
  def start_link(opts \\ []) do
    max_connections = Keyword.get(opts, :max_connections, 100)
    port = Keyword.get(opts, :port, 25565)
    ranch_opts = [port: port, max_connections: max_connections]
    :ranch.start_listener(:minecraft_server, :ranch_tcp, ranch_opts, Minecraft.Protocol, [])
  end
end
