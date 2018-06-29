defmodule Minecraft.Packet.Server.Status do
  @moduledoc false
  defmodule Response do
    @moduledoc false
    import Minecraft.Packet, only: [decode_string: 1, encode_string: 1]

    @type t :: %__MODULE__{packet_id: 0, json: String.t()}

    defstruct packet_id: 0,
              json: nil

    @spec serialize(t) :: {0, binary}
    def serialize(%__MODULE__{json: json}) do
      {0, encode_string(json)}
    end

    @spec deserialize(binary) :: {t, rest :: binary}
    def deserialize(data) do
      {json, rest} = decode_string(data)
      {%__MODULE__{json: json}, rest}
    end
  end

  defmodule Pong do
    @moduledoc false
    defstruct packet_id: 1,
              payload: nil

    @type t :: %__MODULE__{packet_id: 1, payload: integer}

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
