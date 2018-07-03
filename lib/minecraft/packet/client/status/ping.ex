defmodule Minecraft.Packet.Client.Status.Ping do
  @moduledoc false
  @type t :: %__MODULE__{packet_id: 1, payload: integer}
  defstruct packet_id: 1,
            payload: nil

  @spec serialize(t) :: {packet_id :: 1, binary}
  def serialize(%__MODULE__{payload: payload}) do
    {1, <<payload::64-signed>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    <<payload::64-signed, rest::binary>> = data
    {%__MODULE__{payload: payload}, rest}
  end
end
