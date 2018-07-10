defmodule Minecraft.Packet.Server.Play.ChunkData do
  @moduledoc false
  import Bitwise
  import Minecraft.Packet, only: [encode_bool: 1, encode_varint: 1]

  defstruct packet_id: 0x20,
            chunk_x: nil,
            chunk_z: nil,
            ground_up_continuous: true,
            chunk: nil,
            num_block_entities: 0,
            block_entities: nil

  @type t :: %__MODULE__{
          packet_id: 0x20,
          chunk_x: integer,
          chunk_z: integer,
          ground_up_continuous: boolean,
          chunk: Minecraft.Chunk.t(),
          num_block_entities: integer,
          # TODO
          block_entities: nil
        }

  @spec serialize(t) :: {packet_id :: 0x20, binary}
  def serialize(%__MODULE__{} = packet) do
    data = Minecraft.Chunk.serialize(packet.chunk)
    num_sections = Minecraft.Chunk.num_sections(packet.chunk)
    biomes = Minecraft.Chunk.get_biome_data(packet.chunk)
    primary_bit_mask = 0xFFFF >>> (16 - num_sections)
    primary_bit_mask = encode_varint(primary_bit_mask)
    data = IO.iodata_to_binary([data, biomes])
    size = encode_varint(byte_size(data))

    res =
      <<packet.chunk_x::32-integer, packet.chunk_z::32-integer,
        encode_bool(packet.ground_up_continuous)::binary, primary_bit_mask::binary, size::binary,
        data::binary, encode_varint(0)::binary>>

    {0x20, res}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    # <<0::4, creative_mode::1, allow_flying::1, flying::1, invulnerable::1, rest::binary>> = data
    # invulnerable = if invulnerable == 1, do: true, else: false
    # flying = if flying == 1, do: true, else: false
    # allow_flying = if allow_flying == 1, do: true, else: false
    # creative_mode = if creative_mode == 1, do: true, else: false
    # <<flying_speed::32-float, field_of_view_modifier::32-float, rest::binary>> = rest

    # {%__MODULE__{
    #    invulnerable: invulnerable,
    #    flying: flying,
    #    allow_flying: allow_flying,
    #    creative_mode: creative_mode,
    #    flying_speed: flying_speed,
    #    field_of_view_modifier: field_of_view_modifier
    #  }, rest}
    {%__MODULE__{}, data}
  end
end
