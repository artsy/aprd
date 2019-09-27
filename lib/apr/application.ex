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
        start: {Apr.AmqEventService, :start_link, [%{topic: "commerce"}]}
      },
      %{
        id: :conversations,
        start:
          {Aprb.Service.AmqEventService, :start_link,
           [%{topic: "conversations", routing_keys: ["conversation.*"]}]}
      },
      %{
        id: :inquiries,
        start: {Aprb.Service.AmqEventService, :start_link, [%{topic: "inquiries"}]}
      },
      %{
        id: :messages,
        start:
          {Aprb.Service.AmqEventService, :start_link,
           [
             %{
               topic: "radiation.messages",
               routing_keys: ["delivery.spamreport", "delivery.bounce"]
             }
           ]}
      },
      %{
        id: :subscriptions,
        start: {Aprb.Service.AmqEventService, :start_link, [%{topic: "subscriptions"}]}
      },
      %{
        id: :auctions,
        start:
          {Aprb.Service.AmqEventService, :start_link,
           [%{topic: "auctions", routing_keys: ["SecondPriceBidPlaced"]}]}
      },
      %{
        id: :purchases,
        start: {Aprb.Service.AmqEventService, :start_link, [%{topic: "purchases"}]}
      },
      %{id: :sales, start: {Aprb.Service.AmqEventService, :start_link, [%{topic: "sales"}]}},
      %{
        id: :invoices,
        start: {Aprb.Service.AmqEventService, :start_link, [%{topic: "invoices"}]}
      },
      %{
        id: :consignments,
        start: {Aprb.Service.AmqEventService, :start_link, [%{topic: "consignments"}]}
      },
      %{
        id: :feedbacks,
        start: {Aprb.Service.AmqEventService, :start_link, [%{topic: "feedbacks"}]}
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
