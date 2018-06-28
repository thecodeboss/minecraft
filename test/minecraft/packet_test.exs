defmodule Minecraft.PacketTest do
  use ExUnit.Case, async: true
  import Minecraft.Packet

  describe "deserializing varints" do
    test "basics" do
      assert {0, ""} = decode_varint(<<0>>)
      assert {1, ""} = decode_varint(<<1>>)
      assert {2, ""} = decode_varint(<<2>>)
    end

    test "first breakpoint" do
      assert {127, ""} = decode_varint(<<0x7F>>)
      assert {128, ""} = decode_varint(<<0x80, 0x01>>)
      assert {255, ""} = decode_varint(<<0xFF, 0x01>>)
    end

    test "limits" do
      assert {2_147_483_647, ""} = decode_varint(<<0xFF, 0xFF, 0xFF, 0xFF, 0x07>>)
      assert {-1, ""} = decode_varint(<<0xFF, 0xFF, 0xFF, 0xFF, 0x0F>>)
      assert {-2_147_483_648, ""} = decode_varint(<<0x80, 0x80, 0x80, 0x80, 0x08>>)
    end

    test "extra data" do
      assert {0, <<1, 2, 3>>} = decode_varint(<<0, 1, 2, 3>>)
      assert {255, <<1, 2, 3>>} = decode_varint(<<0xFF, 0x01, 1, 2, 3>>)
      assert {-1, <<1, 2, 3>>} = decode_varint(<<0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 1, 2, 3>>)
    end

    test "errors" do
      assert {:error, :too_short} = decode_varint(<<0xFF>>)
      assert {:error, :too_long} = decode_varint(<<0xFF, 0xFF, 0xFF, 0xFF, 0xFF>>)
    end
  end

  describe "deserializing varlongs" do
    test "basics" do
      assert {0, ""} = decode_varlong(<<0>>)
      assert {1, ""} = decode_varlong(<<1>>)
      assert {2, ""} = decode_varlong(<<2>>)
    end

    test "first breakpoint" do
      assert {127, ""} = decode_varlong(<<0x7F>>)
      assert {128, ""} = decode_varlong(<<0x80, 0x01>>)
      assert {255, ""} = decode_varlong(<<0xFF, 0x01>>)
    end

    test "limits" do
      assert {9_223_372_036_854_775_807, ""} =
               decode_varlong(<<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F>>)

      assert {-1, ""} =
               decode_varlong(<<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x01>>)

      assert {-2_147_483_648, ""} =
               decode_varlong(<<0x80, 0x80, 0x80, 0x80, 0xF8, 0xFF, 0xFF, 0xFF, 0xFF, 0x01>>)

      assert {-9_223_372_036_854_775_808, ""} =
               decode_varlong(<<0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x01>>)
    end

    test "extra data" do
      assert {0, <<1, 2, 3>>} = decode_varlong(<<0, 1, 2, 3>>)
      assert {255, <<1, 2, 3>>} = decode_varlong(<<0xFF, 0x01, 1, 2, 3>>)

      assert {-1, <<1, 2, 3>>} =
               decode_varlong(
                 <<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 1, 2, 3>>
               )
    end

    test "errors" do
      assert {:error, :too_short} = decode_varlong(<<0xFF>>)

      assert {:error, :too_long} =
               decode_varlong(<<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF>>)
    end
  end
end
