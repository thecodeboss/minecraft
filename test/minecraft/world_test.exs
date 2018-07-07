defmodule Minecraft.WorldTest do
  use ExUnit.Case, async: true

  test "Generating chunks works" do
    assert [_ | _] = Minecraft.World.get_chunk_data(22, 59)
  end
end
