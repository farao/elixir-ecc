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
