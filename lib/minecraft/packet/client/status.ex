defmodule Minecraft.Packet.Client.Status do
  defmodule Request do
    defstruct packet_id: 0
  end

  defmodule Ping do
    defstruct packet_id: 1,
              payload: nil
  end
end
