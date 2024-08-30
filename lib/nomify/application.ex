defmodule Nomify.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NomifyWeb.Telemetry,
      Nomify.Repo,
      {DNSCluster, query: Application.get_env(:nomify, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Nomify.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Nomify.Finch},
      # Start a worker by calling: Nomify.Worker.start_link(arg)
      # {Nomify.Worker, arg},
      # Start to serve requests, typically the last entry
      NomifyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nomify.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NomifyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
