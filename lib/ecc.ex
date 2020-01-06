defmodule ECC do
  use GenServer

  def start(pem, register_name \\ nil) do
    if register_name do
      GenServer.start(__MODULE__, pem, name: register_name)
    else
      GenServer.start(__MODULE__, pem)
    end
  end

  def start_link(pem, register_name \\ nil) do
    if register_name do
      GenServer.start_link(__MODULE__, pem, name: register_name)
    else
      GenServer.start_link(__MODULE__, pem)
    end
  end

  def init(pem) do
    {:ok,
     %{
       public: ECC.Crypto.parse_public_key(pem),
       private: ECC.Crypto.parse_private_key(pem)
     }}
  end

  def handle_call(:get_public_key, _from, keys) do
    if keys.public do
      {:reply, {:ok, keys.public}, keys}
    else
      {:reply, {:error, :no_public_key}, keys}
    end
  end

  def handle_call({:sign, msg, hash_type}, _from, keys) do
    {:reply, {:ok, ECC.Crypto.sign(msg, hash_type, keys.private)}, keys}
  end

  def handle_call({:verify_signature, msg, signature, public_key, hash_type}, _from, keys) do
    result = ECC.Crypto.verify_signature(msg, signature, hash_type, public_key)
    {:reply, {:ok, result}, keys}
  end
end
