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
    with {:ok, public_key} = ECC.Crypto.parse_public_key(pem),
         {:ok, private_key} = ECC.Crypto.parse_private_key(pem),
         do: {:ok, %{public: public_key, private: private_key}}
  end

  def handle_call(:get_public_key, _from, keys) do
    {:reply, keys.public, keys}
  end

  def handle_call({:sign, msg, hash_type}, _from, keys) do
    {:reply, ECC.Crypto.sign(msg, hash_type, keys.private), keys}
  end

  def handle_call({:verify_signature, msg, signature, public_key, hash_type}, _from, keys) do
    result = ECC.Crypto.verify_signature(msg, signature, hash_type, public_key)
    {:reply, result, keys}
  end
end
