defmodule Minecraft.Packet.Server.Play.KeepAlive do
  @moduledoc false

  defstruct packet_id: 0x1F,
            keep_alive_id: nil

  @type t :: %__MODULE__{packet_id: 0x1F, keep_alive_id: integer}

  @spec serialize(t) :: {packet_id :: 0x1F, binary}
  def serialize(%__MODULE__{keep_alive_id: keep_alive_id}) do
    {0x1F, <<keep_alive_id::64-integer>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    <<keep_alive_id::64-integer, rest::binary>> = data
    {%__MODULE__{keep_alive_id: keep_alive_id}, rest}
  end
end
