defmodule NervesRtcModules.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/elcritch/nerves_rtc_modules"

  def project do
    [
      app: :nerves_rtc_modules,
      version: @version,
      elixir: "~> 1.7",
      description: description(),
      package: package(),
      source_url: @source_url,
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      dialyzer: [
        flags: [:unmatched_returns, :error_handling, :race_conditions, :underspecs]
      ],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
      # mod: {NervesTime.Application, []}
    ]
  end

  defp description do
    "RTC modules for usage with Nerves Time. "
  end

  defp package do
    %{
      files: [
        "lib",
        "src/*.[ch]",
        "test",
        "mix.exs",
        "README.md",
        "LICENSE",
        "CHANGELOG.md",
        "Makefile"
      ],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    }
  end

  defp deps do
    [
      {:nerves_time, "~> 0.4.0", github: "elcritch/nerves_time", branch: "master"},
      {:circuits_gpio, "~> 0.4.2", optional: true},
      {:circuits_i2c, "~> 0.3.4", optional: true},
      {:circuits_spi, "~> 0.1.3", optional: true},
      {:ex_doc, "~> 0.19", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
