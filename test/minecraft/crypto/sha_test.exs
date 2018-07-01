defmodule Minecraft.Crypto.SHATest do
  use ExUnit.Case, async: true
  import Minecraft.Crypto.SHA

  test "sha" do
    assert sha("Notch") == "4ed1f46bbe04bc756bcb17c0c7ce3e4632f06a48"
    assert sha("jeb_") == "-7c9d5b0044c130109a5d7b5fb5c317c02b4e28c1"
    assert sha("simon") == "88e16a1019277b15d58faf0541e11910eb756f6"
  end
end
