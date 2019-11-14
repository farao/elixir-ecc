defmodule ECC.LibTest do
  use ExUnit.Case

  test "signing/checking signatures" do
    pem_public = File.read!("ec_public_key.pem")
    pem_private = File.read!("ec_private_key.pem")
    pem = Enum.join([pem_public, pem_private])

    public_key = ECC.Crypto.parse_public_key(pem)
    private_key = ECC.Crypto.parse_private_key(pem)

    signature = ECC.Crypto.sign("Hello", :sha512, private_key)
    assert ECC.Crypto.verify_signature("Hello", signature, :sha512, public_key)
    assert not ECC.Crypto.verify_signature("World", signature, :sha512, public_key)
  end
end
