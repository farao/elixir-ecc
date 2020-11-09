defmodule ECC.Crypto do
  def parse_public_key(pem) do
    try do
      pem_keys = :public_key.pem_decode(pem)

      ec_params =
        find_entry(pem_keys, :EcpkParameters)
        |> :public_key.pem_entry_decode()

      {:SubjectPublicKeyInfo, pem_public, _} = find_entry(pem_keys, :SubjectPublicKeyInfo)

      {:SubjectPublicKeyInfo, _, ec_point} =
        :public_key.der_decode(:SubjectPublicKeyInfo, pem_public)

      public_key = {{:ECPoint, ec_point}, ec_params}
      {:ok, public_key}
    rescue
      e -> {:error, "Could not find or parse public key: #{e}"}
    end
  end

  def parse_private_key(pem) do
    try do
      private_key =
        pem
        |> :public_key.pem_decode()
        |> find_entry(:ECPrivateKey)
        |> :public_key.pem_entry_decode()

      {:ok, private_key}
    rescue
      e -> {:error, "Could not find or parse private key: #{e}"}
    end
  end

  def sign(msg, hash_type, private_key) do
    try do
      {:ok, :public_key.sign(msg, hash_type, private_key)}
    rescue
      e -> {:error, "Could not sign message: #{e}"}
    end
  end

  def verify_signature(msg, signature, hash_type, public_key) do
    try do
      {:ok, :public_key.verify(msg, hash_type, signature, public_key)}
    rescue
      e -> {:error, "Could not verify signature: #{e}"}
    end
  end

  defp find_entry(list, key) do
    Enum.find(list, &(elem(&1, 0) == key))
  end
end
