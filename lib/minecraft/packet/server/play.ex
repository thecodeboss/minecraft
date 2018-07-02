defmodule Minecraft.Packet.Server.Play do
  @moduledoc false
  defmodule JoinGame do
    @moduledoc false
    import Minecraft.Packet,
      only: [decode_bool: 1, decode_string: 1, encode_bool: 1, encode_string: 1]

    @type game_mode :: :survival | :creative
    @type dimension :: :overworld | :nether | :end
    @type difficulty :: :peaceful | :easy | :normal | :hard
    @type t :: %__MODULE__{
            packet_id: 0x23,
            entity_id: integer,
            game_mode: game_mode,
            dimension: dimension,
            difficulty: difficulty,
            max_players: integer,
            level_type: String.t(),
            reduced_debug_info: boolean
          }

    defstruct packet_id: 0x23,
              entity_id: nil,
              game_mode: :survival,
              dimension: :overworld,
              difficulty: :peaceful,
              max_players: 0,
              level_type: "default",
              reduced_debug_info: false

    @spec serialize(t) :: {packet_id :: 0x23, binary}
    def serialize(%__MODULE__{} = packet) do
      game_mode =
        case packet.game_mode do
          :survival -> 0
          :creative -> 1
        end

      dimension =
        case packet.dimension do
          :nether -> -1
          :overworld -> 0
          :end -> 1
        end

      difficulty =
        case packet.difficulty do
          :peaceful -> 0
          :easy -> 1
          :normal -> 2
          :hard -> 3
        end

      rdi = encode_bool(packet.reduced_debug_info)

      {0x23,
       <<packet.entity_id::32-signed, game_mode::8-unsigned, dimension::32-signed,
         difficulty::8-unsigned, packet.max_players::8-unsigned,
         encode_string(packet.level_type)::binary, rdi::binary>>}
    end

    @spec deserialize(binary) :: {t, rest :: binary}
    def deserialize(data) do
      <<entity_id::32-signed, game_mode::8-unsigned, dimension::32-signed, difficulty::8-unsigned,
        max_players::8-unsigned, rest::binary>> = data

      game_mode =
        case game_mode do
          0 -> :survival
          1 -> :creative
        end

      dimension =
        case dimension do
          -1 -> :nether
          0 -> :overworld
          1 -> :end
        end

      difficulty =
        case difficulty do
          0 -> :peaceful
          1 -> :easy
          2 -> :normal
          3 -> :hard
        end

      {level_type, rest} = decode_string(rest)
      {rdi, rest} = decode_bool(rest)

      {%__MODULE__{
         entity_id: entity_id,
         game_mode: game_mode,
         dimension: dimension,
         difficulty: difficulty,
         max_players: max_players,
         level_type: level_type,
         reduced_debug_info: rdi
       }, rest}
    end
  end

  defmodule SpawnPosition do
    @moduledoc false
    import Minecraft.Packet, only: [decode_position: 1, encode_position: 1]

    defstruct packet_id: 0x46,
              position: nil

    @type t :: %__MODULE__{packet_id: 0x46, position: Minecraft.Packet.position()}

    @spec serialize(t) :: {packet_id :: 0x46, binary}
    def serialize(%__MODULE__{position: position}) do
      {0x46, encode_position(position)}
    end

    @spec deserialize(binary) :: {t, rest :: binary}
    def deserialize(data) do
      {position, rest} = decode_position(data)
      {%__MODULE__{position: position}, rest}
    end
  end

  defmodule PlayerAbilities do
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
end
