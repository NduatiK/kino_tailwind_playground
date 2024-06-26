defmodule KinoTailwindPlayground.MixProject do
  use Mix.Project

  def project do
    [
      app: :kino_tailwind_playground,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {KinoTailwindPlayground.Application, []},
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:kino, "~> 0.12"}
    ]
  end
end
