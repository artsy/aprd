defmodule Apr.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Apr.Repo,
      # Start the endpoint when the application starts
      AprWeb.Endpoint,
      # Starts a worker by calling: Apr.Worker.start_link(arg)
      # {Apr.Worker, arg},
      %{
        id: :commerce,
        start: {Apr.AmqEventService, :start_link, [%{topic: "commerce", store: true}]}
      },
      %{
        id: :conversations,
        start:
          {Apr.AmqEventService, :start_link,
           [%{topic: "conversations", routing_keys: ["conversation.*"]}]}
      },
      %{
        id: :inquiries,
        start: {Apr.AmqEventService, :start_link, [%{topic: "inquiries", store: true}]}
      },
      %{
        id: :messages,
        start:
          {Apr.AmqEventService, :start_link,
           [
             %{
               topic: "radiation.messages",
               routing_keys: ["delivery.spamreport", "delivery.bounce"]
             }
           ]}
      },
      %{
        id: :subscriptions,
        start: {Apr.AmqEventService, :start_link, [%{topic: "subscriptions", store: true}]}
      },
      %{
        id: :auctions,
        start:
          {Apr.AmqEventService, :start_link,
           [%{topic: "auctions", routing_keys: ["SecondPriceBidPlaced"], store: true}]}
      },
      %{
        id: :purchases,
        start: {Apr.AmqEventService, :start_link, [%{topic: "purchases", store: true}]}
      },
      %{id: :sales, start: {Apr.AmqEventService, :start_link, [%{topic: "sales", store: true}]}},
      %{
        id: :invoices,
        start: {Apr.AmqEventService, :start_link, [%{topic: "invoices"}]}
      },
      %{
        id: :consignments,
        start: {Apr.AmqEventService, :start_link, [%{topic: "consignments", store: true}]}
      },
      %{
        id: :feedbacks,
        start: {Apr.AmqEventService, :start_link, [%{topic: "feedbacks"}]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Apr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AprWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
