defmodule Minecraft.Packet.Client.Status do
  @moduledoc false
  defmodule Request do
    @moduledoc false
    defstruct packet_id: 0
  end

  defmodule Ping do
    @moduledoc false
    defstruct packet_id: 1,
              payload: nil
  end
end
