defmodule Minecraft.Packet.Client.Status do
  @moduledoc false
  defmodule Request do
    @moduledoc false
    @type t :: %__MODULE__{packet_id: 0}
    defstruct packet_id: 0

    @spec serialize(t) :: {0, binary}
    def serialize(%__MODULE__{}) do
      {0, ""}
    end

    @spec deserialize(binary) :: {t, rest :: binary}
    def deserialize(data) do
      {%__MODULE__{}, data}
    end
  end

  defmodule Ping do
    @moduledoc false
    @type t :: %__MODULE__{packet_id: 1, payload: integer}
    defstruct packet_id: 1,
              payload: nil

    @spec serialize(t) :: {1, binary}
    def serialize(%__MODULE__{payload: payload}) do
      {1, <<payload::64-signed>>}
    end

    @spec deserialize(binary) :: {t, rest :: binary}
    def deserialize(data) do
      <<payload::64-signed, rest::binary>> = data
      {%__MODULE__{payload: payload}, rest}
    end
  end
end
