Elliptic Curve Cryptography (ECC) for Elixir
=====================

An elixir library for elliptic curve cryptography (MIT License). You can use it to sign messages and to verify signatures with a public key.

### Generate public key pair

Use an existing elliptic curve public key pair or generate one using openssl (adapt the curve name according to your needs):

```
openssl ecparam -out ec_private_key.pem -name secp521r1 -genkey
openssl ec -in ec_private_key.pem -pubout -out ec_public_key.pem
```

### Requirements

Elixir v15.0.0

### Install

Simply add ```{:ecc, "~>0.1.0"}``` to the dependencies in your projects ```mix.exs``` file and run ```mix deps.get ecc```

### Use as GenServer-Module

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

### Use as a library

You can also use ECC.Crypto as a library. The pem-string passed to ECC.Crypto.parse_public_key

```elixir
pem_public = File.read! "ec_public_key.pem"
pem_private = File.read! "ec_private_key.pem"
pem = Enum.join [pem_public, pem_private]

public_key = ECC.Crypto.parse_public_key pem
private_key = ECC.Crypto.parse_private_key pem

signature = ECC.Crypto.sign("Hello", :sha512, private_key)
result = ECC.Crypto.verify_signature("Hello", signature, :sha512, public_key)
IO.puts "Hello == Hello? #{result}" # true

result = not ECC.Crypto.verify_signature("World", signature, :sha512, public_key)
IO.puts "Hello == World? #{result}" # false
```
