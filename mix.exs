defmodule ElixirEllipticCurve.Mixfile do
  use Mix.Project

  def project do
    [app: :ecc,
     version: "0.1.3",
     elixir: "~> 0.14",
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    []
  end

  defp deps do
    []
  end

  def description do
    """
    An elixir module for elliptic curve cryptography.
    It can be used either as a library or as a GenServer-Task
    for signing messages and verifying signatures with a public key.
    """
  end

  defp package do
    [
     files: ["lib", "mix.exs", "README*", "LICENSE*", "ec_*_key.pem", "test"],
     contributors: ["Marius Melzer"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/farao/elixir-ecc"}
   ]
  end
end
