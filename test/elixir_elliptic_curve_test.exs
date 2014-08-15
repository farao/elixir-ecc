defmodule ElixirEllipticCurveTest do
  use ExUnit.Case

  test "signing/checking signatures" do
    pem_public = File.read! "ec_public_key.pem"
    pem_private = File.read! "ec_private_key.pem"
    pem = Enum.join [pem_public, pem_private]

    {:ok, pid} = GenServer.start_link ECC, [pem]
    {:ok, signature} = GenServer.call pid, {:sign, "Hello", :sha512}

    {:ok, public_key} = GenServer.call pid, :get_public_key
    {:ok, result} = GenServer.call pid, {:verify_signature, "Hello", signature, public_key, :sha512}
    assert result

    {:ok, result} = GenServer.call pid, {:verify_signature, "World", signature, public_key, :sha512}
    assert !result
  end
end
