defmodule MinecraftTest do
  use ExUnit.Case
  doctest Minecraft

  test "greets the world" do
    assert Minecraft.hello() == :world
  end
end
