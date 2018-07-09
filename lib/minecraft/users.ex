defmodule Minecraft.Users do
  @moduledoc """
  Stores user data such as position, items, etc.
  """
  use GenServer

  defmodule User do
    @type t :: %__MODULE__{
            uuid: binary,
            username: binary,
            position: {float, float, float},
            look: {float, float},
            respawn_location: {float, float, float}
          }

    defstruct uuid: nil,
              username: nil,
              position: {0.0, 0.0, 0.0},
              look: {0.0, 0.0},
              respawn_location: {0.0, 0.0, 0.0}
  end

  defmodule State do
    @moduledoc false
    @type t :: %__MODULE__{users: %{binary => User.t()}, logged_in: MapSet.t()}
    defstruct users: %{},
              logged_in: MapSet.new()
  end

  @doc """
  Starts the user service.
  """
  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec get_by_uuid(uuid :: binary) :: User.t() | nil
  def get_by_uuid(uuid) do
    GenServer.call(__MODULE__, {:get_by_uuid, uuid})
  end

  @spec get_by_username(username :: binary) :: User.t() | nil
  def get_by_username(username) do
    GenServer.call(__MODULE__, {:get_by_username, username})
  end

  @spec update_look(binary, {float, float}) :: :ok
  def update_look(uuid, look) do
    GenServer.cast(__MODULE__, {:update_look, uuid, look})
  end

  @spec update_position(binary, {float, float, float}) :: :ok
  def update_position(uuid, new_position) do
    GenServer.cast(__MODULE__, {:update_position, uuid, new_position})
  end

  @spec join(binary, binary) :: :ok
  def join(uuid, username) do
    GenServer.cast(__MODULE__, {:join, uuid, username})
  end

  #
  # Callbacks
  #

  @impl true
  def init(_opts) do
    {:ok, %State{}}
  end

  @impl true
  def handle_call({:get_by_uuid, uuid}, _from, %{users: users} = state) do
    {:reply, Map.get(users, uuid), state}
  end

  def handle_call({:get_by_username, username}, _from, %{users: users} = state) do
    {:reply, Enum.find(users, fn {_uuid, user} -> user.username == username end), state}
  end

  @impl true
  def handle_cast({:update_look, uuid, look}, state) do
    users = Map.update!(state.users, uuid, fn user -> %User{user | look: look} end)
    {:noreply, %{state | users: users}}
  end

  def handle_cast({:update_position, uuid, position}, state) do
    users = Map.update!(state.users, uuid, fn user -> %User{user | position: position} end)
    {:noreply, %{state | users: users}}
  end

  def handle_cast({:join, uuid, username}, state) do
    state = %{state | logged_in: MapSet.put(state.logged_in, uuid)}

    if is_nil(state.users[uuid]) do
      users = Map.put(state.users, uuid, %User{uuid: uuid, username: username})
      {:noreply, %{state | users: users}}
    else
      {:noreply, state}
    end
  end
end
