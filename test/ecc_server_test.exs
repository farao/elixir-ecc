defmodule ECC.ServerTest do
  use ExUnit.Case

  test "signing/checking signatures" do
    pem_public = File.read!("ec_public_key.pem")
    pem_private = File.read!("ec_private_key.pem")
    pem = Enum.join([pem_public, pem_private])

    {:ok, _} = ECC.start_link(pem, :ecc)
    {:ok, signature} = GenServer.call(:ecc, {:sign, "Hello", :sha512})

    public_key = GenServer.call(:ecc, :get_public_key)

    {:ok, result} =
      GenServer.call(:ecc, {:verify_signature, "Hello", signature, public_key, :sha512})

    assert result

    {:ok, result} =
      GenServer.call(:ecc, {:verify_signature, "World", signature, public_key, :sha512})

    assert not result
  end
end
