defmodule Minecraft.Crypto.SHA do
  @moduledoc """
  Minecraft uses a [non-standard SHA encoding](http://wiki.vg/Protocol_Encryption#Authentication), and
  this module implements it.
  """

  @doc """
  Generates the Minecraft SHA of a binary.
  """
  @spec sha(binary) :: String.t()
  def sha(message) do
    case :crypto.hash(:sha, message) do
      <<hash::signed-integer-160>> when hash < 0 ->
        "-" <> String.downcase(Integer.to_string(-hash, 16))

      <<hash::signed-integer-160>> ->
        String.downcase(Integer.to_string(hash, 16))
    end
  end
end
