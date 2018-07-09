defmodule Minecraft.WorldTest do
  use ExUnit.Case, async: true

  test "Generating chunks works" do
    assert %Minecraft.Chunk{} = Minecraft.World.get_chunk(22, 59)
  end
end
