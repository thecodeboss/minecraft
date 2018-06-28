defmodule Minecraft.PacketTest do
  use ExUnit.Case, async: true
  import Minecraft.Packet

  describe "deserializing varints" do
    test "basics" do
      assert {0, ""} = deserialize_varint(<<0>>)
      assert {1, ""} = deserialize_varint(<<1>>)
      assert {2, ""} = deserialize_varint(<<2>>)
    end

    test "first breakpoint" do
      assert {127, ""} = deserialize_varint(<<0x7F>>)
      assert {128, ""} = deserialize_varint(<<0x80, 0x01>>)
      assert {255, ""} = deserialize_varint(<<0xFF, 0x01>>)
    end

    test "limits" do
      assert {2_147_483_647, ""} = deserialize_varint(<<0xFF, 0xFF, 0xFF, 0xFF, 0x07>>)
      assert {-1, ""} = deserialize_varint(<<0xFF, 0xFF, 0xFF, 0xFF, 0x0F>>)
      assert {-2_147_483_648, ""} = deserialize_varint(<<0x80, 0x80, 0x80, 0x80, 0x08>>)
    end

    test "extra data" do
      assert {0, <<1, 2, 3>>} = deserialize_varint(<<0, 1, 2, 3>>)
      assert {255, <<1, 2, 3>>} = deserialize_varint(<<0xFF, 0x01, 1, 2, 3>>)
      assert {-1, <<1, 2, 3>>} = deserialize_varint(<<0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 1, 2, 3>>)
    end

    test "errors" do
      assert {:error, :too_short} = deserialize_varint(<<0xFF>>)
      assert {:error, :too_long} = deserialize_varint(<<0xFF, 0xFF, 0xFF, 0xFF, 0xFF>>)
    end
  end

  describe "deserializing varlongs" do
    test "basics" do
      assert {0, ""} = deserialize_varlong(<<0>>)
      assert {1, ""} = deserialize_varlong(<<1>>)
      assert {2, ""} = deserialize_varlong(<<2>>)
    end

    test "first breakpoint" do
      assert {127, ""} = deserialize_varlong(<<0x7F>>)
      assert {128, ""} = deserialize_varlong(<<0x80, 0x01>>)
      assert {255, ""} = deserialize_varlong(<<0xFF, 0x01>>)
    end

    test "limits" do
      assert {9_223_372_036_854_775_807, ""} =
               deserialize_varlong(<<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F>>)

      assert {-1, ""} =
               deserialize_varlong(<<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x01>>)

      assert {-2_147_483_648, ""} =
               deserialize_varlong(<<0x80, 0x80, 0x80, 0x80, 0xF8, 0xFF, 0xFF, 0xFF, 0xFF, 0x01>>)

      assert {-9_223_372_036_854_775_808, ""} =
               deserialize_varlong(<<0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x01>>)
    end

    test "extra data" do
      assert {0, <<1, 2, 3>>} = deserialize_varlong(<<0, 1, 2, 3>>)
      assert {255, <<1, 2, 3>>} = deserialize_varlong(<<0xFF, 0x01, 1, 2, 3>>)

      assert {-1, <<1, 2, 3>>} =
               deserialize_varlong(
                 <<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 1, 2, 3>>
               )
    end

    test "errors" do
      assert {:error, :too_short} = deserialize_varlong(<<0xFF>>)

      assert {:error, :too_long} =
               deserialize_varlong(<<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF>>)
    end
  end
end
