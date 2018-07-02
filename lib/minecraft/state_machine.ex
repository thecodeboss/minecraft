defmodule Minecraft.StateMachine do
  @moduledoc """
  Implements core Minecraft logic.

  Minecraft can be thought of as a finite state machine, where transitions occur based on
  client interactions and server intervention. This module implements the `:gen_statem`
  behaviour.
  """
  alias Minecraft.Packet.Server
  alias Minecraft.Protocol
  @behaviour :gen_statem

  @doc """
  Starts the state machine.
  """
  @spec start_link(protocol :: pid) :: :gen_statem.start_ret()
  def start_link(protocol) do
    :gen_statem.start_link(__MODULE__, protocol, [])
  end

  @impl true
  def callback_mode() do
    :state_functions
  end

  @impl true
  def init(protocol) do
    {:ok, :join, protocol, [{:next_event, :internal, "hello"}]}
  end

  @impl true
  def terminate(_reason, _state, _data) do
    # We don't need to log errors here, since whatever killed this will log an error
    :ignored
  end

  @doc """
  State entered when a client logs in and begins joining the server.
  """
  @spec join(:internal, any, pid) :: {:next_state, :ready, pid}
  def join(:internal, _, protocol) do
    :ok = Protocol.send_packet(protocol, %Server.Play.JoinGame{entity_id: 123})
    :ok = Protocol.send_packet(protocol, %Server.Play.SpawnPosition{position: {0, 64, 0}})
    :ok = Protocol.send_packet(protocol, %Server.Play.PlayerAbilities{})
    {:next_state, :ready, protocol}
  end
end
