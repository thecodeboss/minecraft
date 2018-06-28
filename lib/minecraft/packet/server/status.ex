defmodule Minecraft.Packet.Server.Status do
  defmodule Response do
    defstruct packet_id: 0,
              json: nil
  end

  defmodule Pong do
    defstruct packet_id: 1,
              payload: nil
  end
end
