defmodule ECC do
  use GenServer

  def start_link(pem) do
    GenServer.start_link(__MODULE__, pem)
  end

  def init(pem) do
    {:ok, %{
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
        Enum.find(pem_keys, fn(k) -> elem(k,0) == :OTPEcpkParameters end)
        |> put_elem(0, :EcpkParameters)
        |> :public_key.pem_entry_decode

      pem_public =
        Enum.find(pem_keys, fn(k) -> elem(k,0) == :SubjectPublicKeyInfo end)
        |> elem(1)
      ec_point = :public_key.der_decode(:SubjectPublicKeyInfo, pem_public)
        |> elem(2)
        |> elem(1)

      {{:ECPoint, ec_point}, ec_params}
    rescue
      _ -> nil
    end
  end

  def parse_private_key(pem) do
    try do
      :public_key.pem_decode(pem)
      |> Enum.find(fn(k) -> elem(k,0) == :ECPrivateKey end)
      |> :public_key.pem_entry_decode
    rescue
      _ -> nil
    end
  end

  def sign(msg, hash_type, private_key) do
    try do
      :public_key.sign msg, hash_type, private_key
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
