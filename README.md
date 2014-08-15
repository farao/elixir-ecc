elixir-elliptic-curve
=====================

An elixir module for elliptic curve cryptography (MIT licence). You can use it to sign messages and to verify signatures with a public key.

## Generate public key pair

Use an existing elliptic curve public key pair or generate one using openssl (adapt the curve name according to your needs):

```
openssl ecparam -out ec_private_key.pem -name secp521r1 -genkey
openssl ec -in ec_private_key.pem -pubout -out ec_public_key.pem
```

## Install

Copy the ECC-Module-File into your project.

## Use

ECC is a GenServer-Module. You can start a new process passing in both the private and the public key combined in one (still pem-style) string:

```elixir
pem_public = File.read! "ec_public_key.pem"
pem_private = File.read! "ec_private_key.pem"
pem = Enum.join [pem_public, pem_private]

{:ok, pid} = GenServer.start_link ECC, [pem]
{:ok, signature} = GenServer.call pid, {:sign, "Hello", :sha512}

{:ok, public_key} = GenServer.call pid, :get_public_key
{:ok, result} = GenServer.call pid, {:verify_signature, "Hello", signature, public_key, :sha512}
IO.puts "Hello == Hello? #{result}" # true

{:ok, result} = GenServer.call pid, {:verify_signature, "World", signature, public_key, :sha512}
IO.puts "Hello == World? #{result}" # false
```
