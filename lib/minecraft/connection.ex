defmodule Minecraft.Connection do
  @moduledoc """
  Maintains the state of a client's connection, and provides utilities for sending and receiving
  data. It is designed to be chained in a fashion similar to [`Plug`](https://hexdocs.pm/plug/).
  """
  alias Minecraft.Crypto
  alias Minecraft.Packet
  require Logger

  @has_joined_url "https://sessionserver.mojang.com/session/minecraft/hasJoined?"

  @typedoc """
  The possible states a client/server can be in.
  """
  @type state :: :handshake | :status | :login | :play

  @typedoc """
  Allowed ranch transport types.
  """
  @type transport :: :ranch_tcp

  @type t :: %__MODULE__{
          assigns: %{atom => any} | nil,
          current_state: state,
          socket: port | nil,
          transport: transport | nil,
          client_ip: String.t(),
          data: binary | nil,
          error: any,
          protocol_version: integer | nil,
          secret: binary | nil
        }

  defstruct assigns: nil,
            current_state: nil,
            aes: nil,
            socket: nil,
            transport: nil,
            client_ip: nil,
            data: nil,
            error: nil,
            protocol_version: nil,
            secret: nil

  @doc """
  Assigns a value to a key in the connection.
  ## Examples
      iex> conn.assigns[:hello]
      nil
      iex> conn = assign(conn, :hello, :world)
      iex> conn.assigns[:hello]
      :world
  """
  @spec assign(t, atom, term) :: t
  def assign(%__MODULE__{assigns: assigns} = conn, key, value) when is_atom(key) do
    %{conn | assigns: Map.put(assigns, key, value)}
  end

  @doc """
  Closes the `Connection`.
  """
  @spec close(t) :: t
  def close(conn) do
    :ok = conn.transport.close(conn.socket)
    %__MODULE__{conn | socket: nil, transport: nil}
  end

  @doc """
  Continues receiving messages from the client.

  To prevent a client from flooding our process mailbox, we only receive one message at a time,
  and explicitly `continue` to receive messages once we finish processing the ones we have.
  """
  @spec continue(t) :: t
  def continue(conn) do
    :ok = conn.transport.setopts(conn.socket, active: :once)
    conn
  end

  @doc """
  Starts encrypting messages sent/received over this `Connection`.
  """
  @spec encrypt(t, binary) :: t
  def encrypt(conn, secret) do
    aes = %Crypto.AES{key: secret, ivec: secret}
    %__MODULE__{conn | aes: aes, secret: secret}
  end

  @doc """
  Initializes a `Connection`.
  """
  @spec init(port(), transport()) :: t
  def init(socket, transport) do
    {:ok, {client_ip, _port}} = :inet.peername(socket)
    client_ip = IO.iodata_to_binary(:inet.ntoa(client_ip))
    :ok = transport.setopts(socket, active: :once)

    Logger.info(fn -> "Client #{client_ip} connected." end)

    %__MODULE__{
      assigns: %{},
      current_state: :handshake,
      socket: socket,
      transport: transport,
      client_ip: client_ip,
      data: ""
    }
  end

  @doc """
  Communicates with Mojang servers to verify user login.
  """
  @spec verify_login(t) :: t | {:error, :failed_login_verification}
  def verify_login(%__MODULE__{} = conn) do
    public_key = Crypto.get_public_key()
    username = conn.assigns[:username]
    hash = Crypto.SHA.sha(conn.secret <> public_key)

    query_params = URI.encode_query(%{username: username, serverId: hash})
    url = @has_joined_url <> query_params

    with %{body: body, status_code: 200} <- HTTPoison.get!(url),
         %{"id" => uuid, "name" => ^username} <- Poison.decode!(body) do
      assign(conn, :uuid, normalize_uuid(uuid))
    else
      _ ->
        {:error, :failed_login_verification}
    end
  end

  @doc """
  Stores data received from the client in this `Connection`.
  """
  @spec put_data(t, binary) :: t
  def put_data(conn, data) do
    %__MODULE__{conn | data: conn.data <> data}
  end

  @doc """
  Puts the `Connection` into the given `error` state.
  """
  @spec put_error(t, any) :: t
  def put_error(conn, error) do
    %__MODULE__{conn | error: error}
  end

  @doc """
  Sets the protocol for the `Connection`.
  """
  @spec put_protocol(t, integer) :: t
  def put_protocol(conn, protocol_version) do
    %__MODULE__{conn | protocol_version: protocol_version}
  end

  @doc """
  Replaces the `Connection`'s underlying socket.
  """
  @spec put_socket(t, port()) :: t
  def put_socket(conn, socket) do
    %__MODULE__{conn | socket: socket}
  end

  @doc """
  Updates the `Connection` state.
  """
  @spec put_state(t, state) :: t
  def put_state(conn, state) do
    %__MODULE__{conn | current_state: state}
  end

  @doc """
  Pops a packet from the `Connection`.
  """
  @spec read_packet(t) :: {:ok, struct, t} | {:error, t}
  def read_packet(conn) do
    case Packet.deserialize(conn.data, conn.current_state) do
      {packet, rest} when is_binary(rest) ->
        Logger.debug(fn -> "REQUEST: #{inspect(packet)}" end)
        {:ok, packet, %__MODULE__{conn | data: rest}}

      {:error, :invalid_packet} ->
        Logger.error(fn ->
          "Received an invalid packet from client, closing connection. #{inspect(conn.data)}"
        end)

        {:error, put_error(conn, :invalid_packet)}
    end
  end

  @doc """
  Sends a response to the client.
  """
  @spec send_response(t, struct) :: t
  def send_response(conn, response) do
    Logger.debug(fn -> "RESPONSE: #{inspect(response)}" end)

    {:ok, response} = Packet.serialize(response)
    {response, conn} = maybe_encrypt(response, conn)

    :ok = conn.transport.send(conn.socket, response)
    conn
  end

  defp maybe_encrypt(response, %__MODULE__{aes: nil} = conn) do
    {response, conn}
  end

  defp maybe_encrypt(response, conn) do
    {encrypted, aes} = Crypto.AES.encrypt(response, conn.aes)
    {encrypted, %__MODULE__{conn | aes: aes}}
  end

  defp normalize_uuid(<<a::8-binary, b::4-binary, c::4-binary, d::4-binary, e::12-binary>>) do
    "#{a}-#{b}-#{c}-#{d}-#{e}"
  end
end
