defmodule OkJose.Mixfile do
  use Mix.Project

  def project do
    [app: :ok_jose,
     version: "2.0.0",
     description: description,
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  def description do
    """
    Pipe functions that produce ok/error tuples.
    """
  end

  defp package do
    [files: ["lib", "mix.exs", "README*"],
     maintainers: ["Victor Borja"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/vic/ok_jose"}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:mix_test_watch, "~> 0.2", only: :dev},
     {:credo, "~> 0.2.4", only: :dev}]
  end
end
