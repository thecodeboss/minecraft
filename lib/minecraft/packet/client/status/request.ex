defmodule Minecraft.Packet.Client.Status.Request do
  @moduledoc false
  @type t :: %__MODULE__{packet_id: 0}
  defstruct packet_id: 0

  @spec serialize(t) :: {packet_id :: 0, binary}
  def serialize(%__MODULE__{}) do
    {0, ""}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    {%__MODULE__{}, data}
  end
end
