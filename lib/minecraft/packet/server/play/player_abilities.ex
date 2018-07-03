defmodule Minecraft.Packet.Server.Play.PlayerAbilities do
  @moduledoc false
  defstruct packet_id: 0x2C,
            invulnerable: false,
            flying: false,
            allow_flying: false,
            creative_mode: false,
            flying_speed: 0.0,
            field_of_view_modifier: 1.0

  @type t :: %__MODULE__{
          packet_id: 0x2C,
          invulnerable: boolean,
          flying: boolean,
          allow_flying: boolean,
          creative_mode: boolean,
          flying_speed: float,
          field_of_view_modifier: float
        }

  @spec serialize(t) :: {packet_id :: 0x2C, binary}
  def serialize(%__MODULE__{} = packet) do
    invulnerable = if packet.invulnerable, do: 1, else: 0
    flying = if packet.flying, do: 1, else: 0
    allow_flying = if packet.allow_flying, do: 1, else: 0
    creative_mode = if packet.creative_mode, do: 1, else: 0
    flags = <<0::4, creative_mode::1, allow_flying::1, flying::1, invulnerable::1>>

    {0x2C,
     <<flags::binary, packet.flying_speed::32-float, packet.field_of_view_modifier::32-float>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    <<0::4, creative_mode::1, allow_flying::1, flying::1, invulnerable::1, rest::binary>> = data
    invulnerable = if invulnerable == 1, do: true, else: false
    flying = if flying == 1, do: true, else: false
    allow_flying = if allow_flying == 1, do: true, else: false
    creative_mode = if creative_mode == 1, do: true, else: false
    <<flying_speed::32-float, field_of_view_modifier::32-float, rest::binary>> = rest

    {%__MODULE__{
       invulnerable: invulnerable,
       flying: flying,
       allow_flying: allow_flying,
       creative_mode: creative_mode,
       flying_speed: flying_speed,
       field_of_view_modifier: field_of_view_modifier
     }, rest}
  end
end
