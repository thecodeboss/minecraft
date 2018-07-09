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
    [:state_functions, :state_enter]
  end

  @impl true
  def init(protocol) do
    {:ok, :join, protocol, [{:next_event, :internal, nil}]}
  end

  @impl true
  def terminate(_reason, _state, _data) do
    # We don't need to log errors here, since whatever killed this will log an error
    :ignored
  end

  @doc """
  State entered when a client logs in and begins joining the server.
  """
  @spec join(:internal, any, pid) :: {:keep_state, pid}
  def join(:internal, _, protocol) do
    conn = Protocol.get_conn(protocol)
    :ok = Minecraft.Users.join(conn.assigns[:uuid], conn.assigns[:username])

    :ok = Protocol.send_packet(protocol, %Server.Play.JoinGame{entity_id: 123})
    :ok = Protocol.send_packet(protocol, %Server.Play.SpawnPosition{position: {0, 200, 0}})
    :ok = Protocol.send_packet(protocol, %Server.Play.PlayerAbilities{})

    :ok =
      Protocol.send_packet(protocol, %Server.Play.PlayerPositionAndLook{
        teleport_id: :rand.uniform(127)
      })

    {:next_state, :spawn, protocol, [{:next_event, :internal, nil}]}
  end

  def join(:enter, _, protocol) do
    {:keep_state, protocol}
  end

  def spawn(:internal, _, protocol) do
    for r <- 0..32 do
      for x <- -r..r do
        for z <- -r..r do
          if (x * x + z * z <= r * r and x * x + z * z > (r - 1) * (r - 1)) or r == 0 do
            chunk = Minecraft.World.get_chunk(x, z)

            :ok =
              Protocol.send_packet(protocol, %Server.Play.ChunkData{
                chunk_x: x,
                chunk_z: z,
                chunk: chunk
              })
          end
        end
      end
    end

    {:next_state, :ready, protocol, [{:state_timeout, 1000, :keepalive}]}
  end

  def spawn(:enter, _, protocol) do
    {:keep_state, protocol}
  end

  def ready(:enter, _, protocol) do
    {:keep_state, protocol}
  end

  def ready(:state_timeout, :keepalive, protocol) do
    :ok =
      Protocol.send_packet(protocol, %Server.Play.KeepAlive{
        keep_alive_id: System.system_time(:millisecond)
      })

    {:keep_state, protocol, [{:state_timeout, 1000, :keepalive}]}
  end
end
