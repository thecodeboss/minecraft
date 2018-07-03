defmodule Minecraft.Packet.Client.Play.ClientSettings do
  @moduledoc false
  import Minecraft.Packet,
    only: [
      decode_bool: 1,
      decode_string: 1,
      decode_varint: 1,
      encode_bool: 1,
      encode_string: 1,
      encode_varint: 1
    ]

  @type t :: %__MODULE__{
          packet_id: 4,
          locale: String.t(),
          view_distance: integer,
          chat_mode: integer,
          chat_colors: boolean,
          displayed_skin_parts: integer,
          main_hand: :left | :right
        }
  defstruct packet_id: 4,
            locale: "en_us",
            view_distance: 8,
            chat_mode: 0,
            chat_colors: true,
            displayed_skin_parts: 0,
            main_hand: :right

  @spec serialize(t) :: {packet_id :: 4, binary}
  def serialize(%__MODULE__{} = packet) do
    main_hand =
      case packet.main_hand do
        :left -> 0
        :right -> 1
      end

    {4,
     <<encode_string(packet.locale)::binary, packet.view_distance::8,
       encode_varint(packet.chat_mode)::binary, encode_bool(packet.chat_colors)::binary,
       packet.displayed_skin_parts::8-unsigned, encode_varint(main_hand)::binary>>}
  end

  @spec deserialize(binary) :: {t, rest :: binary}
  def deserialize(data) do
    {locale, rest} = decode_string(data)
    <<view_distance::8, rest::binary>> = rest
    {chat_mode, rest} = decode_varint(rest)
    {chat_colors, rest} = decode_bool(rest)
    <<displayed_skin_parts::8-unsigned, rest::binary>> = rest
    {main_hand, rest} = decode_varint(rest)
    main_hand = if main_hand == 0, do: :left, else: :right

    {%__MODULE__{
       locale: locale,
       view_distance: view_distance,
       chat_mode: chat_mode,
       chat_colors: chat_colors,
       displayed_skin_parts: displayed_skin_parts,
       main_hand: main_hand
     }, rest}
  end
end
