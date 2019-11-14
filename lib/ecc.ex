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

defmodule ECC.Crypto do
  def parse_public_key(pem) do
    try do
      pem_keys = :public_key.pem_decode(pem)

      ec_params =
        pem_keys
        |> Enum.find(&(elem(&1, 0) == :EcpkParameters))
        |> :public_key.pem_entry_decode()

      pem_public =
        pem_keys
        |> Enum.find(&(elem(&1, 0) == :SubjectPublicKeyInfo))
        |> elem(1)

      ec_point =
        :SubjectPublicKeyInfo
        |> :public_key.der_decode(pem_public)
        |> elem(2)

      {{:ECPoint, ec_point}, ec_params}
    rescue
      _ ->
        nil
    end
  end

  def parse_private_key(pem) do
    try do
      pem
      |> :public_key.pem_decode()
      |> Enum.find(&(elem(&1, 0) == :ECPrivateKey))
      |> :public_key.pem_entry_decode()
    rescue
      _ -> nil
    end
  end

  def sign(msg, hash_type, private_key) do
    try do
      :public_key.sign(msg, hash_type, private_key)
    rescue
      _ -> nil
    end
  end

  def verify_signature(msg, signature, hash_type, public_key) do
    try do
      :public_key.verify(msg, hash_type, signature, public_key)
    rescue
      _ -> nil
    end
  end
end
