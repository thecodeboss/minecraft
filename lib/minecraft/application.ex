defmodule Minecraft.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Minecraft.Crypto,
      Minecraft.World,
      Minecraft.Users,
      Minecraft.Server
    ]

    opts = [strategy: :one_for_one, name: Minecraft.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
