defmodule Minecraft.Packet.Server.Status do
  @moduledoc false
  defmodule Response do
    @moduledoc false
    defstruct packet_id: 0,
              json: nil
  end

  defmodule Pong do
    @moduledoc false
    defstruct packet_id: 1,
              payload: nil
  end
end
