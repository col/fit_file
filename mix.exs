defmodule FitFile.MixProject do
  use Mix.Project

  def project do
    [
      app: :fit_file,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler, "~> 0.36.1", optional: true, runtime: false},
      {:rustler_precompiled, "~> 0.8.0"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Elixir wrapper for the Rust fitparser library to parse ANT FIT files"
  end

  defp package do
    [
      name: "fit_file",
      files: ~w(lib native .formatter.exs mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/yourusername/fit_file"}
    ]
  end

  defp docs do
    [
      main: "FitFile",
      extras: ["README.md"]
    ]
  end
end
