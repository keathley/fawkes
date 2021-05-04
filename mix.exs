defmodule Fawkes.MixProject do
  use Mix.Project

  @version "0.4.1"

  def project do
    [
      app: :fawkes,
      version: @version,
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Fawkes",
      source_url: "https://github.com/keathley/fawkes",
      docs: docs()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_stage, "~> 1.0"},
      {:redix, "~> 1.0"},
      {:websocket_client, "~> 1.3"},
      {:finch, "~> 0.3"},
      {:jason, "~> 1.2"},
      {:mentat, "~> 0.2"},

      {:credo, "~> 1.4", only: [:dev, :test]},
      {:ex_doc, "~> 0.19", only: [:dev, :test]},
    ]
  end

  def description do
    """
    Fawkes is a system for building chatbots.
    """
  end

  def package do
    [
      name: "fawkes",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/keathley/fawkes"}
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      source_url: "https://github.com/keathley/fawkes",
      main: "Fawkes",
      groups_for_modules: [
        "Events": [
          Fawkes.Event.Message,
          Fawkes.Event.ReactionAdded,
          Fawkes.Event.ReactionRemoved,
          Fawkes.Event.TopicChanged,
          Fawkes.Event.ChannelJoined,
          Fawkes.Event.ChannelLeft,
        ]
      ]
    ]
  end
end
