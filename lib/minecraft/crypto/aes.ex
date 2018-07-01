defmodule Minecraft.Crypto.AES do
  @moduledoc """
  Helper module for encrypting/decrypting using AES/CFB8.
  """

  @type t :: %__MODULE__{key: binary, ivec: binary}

  defstruct key: nil, ivec: nil

  @doc """
  Decrypts a `message`, given the current AES `state`.
  """
  @spec decrypt(binary, t) :: {decrypted_message :: binary, new_state :: t}
  def decrypt(message, state) do
    decrypt(message, state, [])
  end

  defp decrypt(<<head::1-binary, rest::binary>>, %__MODULE__{} = state, decrypted) do
    plain_text = :crypto.block_decrypt(:aes_cfb8, state.key, state.ivec, head)
    <<_::1-binary, ivec::binary>> = state.ivec <> head
    decrypt(rest, %__MODULE__{state | ivec: ivec}, [decrypted | plain_text])
  end

  defp decrypt("", state, decrypted) do
    {IO.iodata_to_binary(decrypted), state}
  end

  @doc """
  Encrypts a `message`, given the current AES `state`.
  """
  @spec encrypt(binary, t) :: {encrypted_message :: binary, new_state :: t}
  def encrypt(message, state) do
    encrypt(message, state, [])
  end

  defp encrypt(<<head::1-binary, rest::binary>>, %__MODULE__{} = state, encrypted) do
    cipher_text = :crypto.block_encrypt(:aes_cfb8, state.key, state.ivec, head)
    <<_::1-binary, ivec::binary>> = state.ivec <> cipher_text
    encrypt(rest, %__MODULE__{state | ivec: ivec}, [encrypted | cipher_text])
  end

  defp encrypt("", state, encrypted) do
    {IO.iodata_to_binary(encrypted), state}
  end
end
