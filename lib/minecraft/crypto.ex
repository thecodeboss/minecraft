defmodule Minecraft.Crypto do
  @moduledoc """
  Module for managing cryptographic keys.
  """
  use GenServer
  require Logger

  @doc """
  Starts the Crypto server, which generates keys during initialization.
  """
  @spec start_link(opts :: Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Gets the public key.
  """
  @spec get_public_key() :: binary
  def get_public_key() do
    GenServer.call(__MODULE__, :get_public_key)
  end

  @doc """
  Encrypts a message.
  """
  @spec encrypt(message :: binary) :: binary
  def encrypt(message) do
    GenServer.call(__MODULE__, {:encrypt, message})
  end

  @doc """
  Decrypts a message.
  """
  @spec decrypt(message :: binary) :: binary
  def decrypt(message) do
    GenServer.call(__MODULE__, {:decrypt, message})
  end

  @impl true
  def init(_opts) do
    {priv_key_file, pub_key_file} = gen_keys()
    {priv_key, pub_key, pub_key_der} = load_keys(priv_key_file, pub_key_file)

    state = %{
      priv_key_file: priv_key_file,
      pub_key_file: pub_key_file,
      priv_key: priv_key,
      pub_key: pub_key,
      pub_key_der: pub_key_der
    }

    {:ok, state}
  end

  @impl true
  def terminate(reason, %{priv_key_file: priv_key_file}) do
    temp_dir = Path.dirname(priv_key_file)
    {:ok, _} = File.rm_rf(temp_dir)
    {:stop, reason, %{}}
  end

  @impl true
  def handle_call(:get_keys_dir, _from, %{priv_key_file: priv_key_file} = state) do
    {:reply, Path.dirname(priv_key_file), state}
  end

  def handle_call(:get_public_key, _from, %{pub_key_der: pub_key_der} = state) do
    {:reply, pub_key_der, state}
  end

  def handle_call({:decrypt, message}, _from, %{priv_key: priv_key} = state) do
    message = :public_key.decrypt_private(message, priv_key)
    {:reply, message, state}
  end

  def handle_call({:encrypt, message}, _from, %{pub_key: pub_key} = state) do
    message = :public_key.encrypt_public(message, pub_key)
    {:reply, message, state}
  end

  defp gen_keys() do
    {temp_dir, 0} = System.cmd("mktemp", ["-d"])
    temp_dir = String.trim(temp_dir)
    priv_key_file = Path.join(temp_dir, "mc_private_key.pem")
    pub_key_file = Path.join(temp_dir, "mc_public_key.pem")

    {_, 0} = System.cmd("openssl", ~w(genrsa -out #{priv_key_file} 1024), stderr_to_stdout: true)

    {_, 0} =
      System.cmd(
        "openssl",
        ~w(rsa -in #{priv_key_file} -out #{pub_key_file} -outform PEM -pubout),
        stderr_to_stdout: true
      )

    Logger.debug(fn -> "Generated RSA keypair in #{temp_dir}" end)
    {priv_key_file, pub_key_file}
  end

  defp load_keys(priv_key_file, pub_key_file) do
    priv_key_pem = File.read!(priv_key_file)
    pub_key_pem = File.read!(pub_key_file)

    [priv_entry] = :public_key.pem_decode(priv_key_pem)
    priv_key = :public_key.pem_entry_decode(priv_entry)

    [pub_entry] = :public_key.pem_decode(pub_key_pem)
    pub_key = :public_key.pem_entry_decode(pub_entry)
    {:SubjectPublicKeyInfo, pub_key_der, _} = pub_entry

    {priv_key, pub_key, pub_key_der}
  end
end
