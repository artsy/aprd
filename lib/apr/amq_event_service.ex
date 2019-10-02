defmodule Apr.AmqEventService do
  @behaviour GenServer
  use GenServer
  use AMQP

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  @impl GenServer
  def init(opts) do
    rabbitmq_connect(opts)
  end

  defp rabbitmq_connect(opts) do
    %{topic: topic, routing_keys: routing_keys} = Map.merge(%{routing_keys: ["#"]}, opts)

    case Connection.open(Application.get_env(:apr, RabbitMQ)) do
      {:ok, conn} ->
        # Get notifications when the connection goes down
        Process.monitor(conn.pid)
        {:ok, chan} = Channel.open(conn)
        Basic.qos(chan, prefetch_count: 10)
        Exchange.topic(chan, topic, durable: true)
        queue_name = "apr_#{topic}_queue"
        Queue.declare(chan, queue_name, durable: true)

        for routing_key <- routing_keys,
            do: Queue.bind(chan, queue_name, topic, routing_key: routing_key)

        {:ok, _consumer_tag} = Basic.consume(chan, queue_name)
        {:ok, {chan, opts}}

      {:error, message} ->
        IO.inspect(message)
        # Reconnection loop
        :timer.sleep(10000)
        rabbitmq_connect(opts)
    end
  end

  # 2. Implement a callback to handle DOWN notifications from the system
  #    This callback should try to reconnect to the server

  def handle_info({:DOWN, _, :process, _pid, _reason}, {_chan, opts}) do
    {:ok, {chan, opts}} = rabbitmq_connect(opts)
    {:noreply, {chan, opts}}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, {chan, opts}) do
    {:noreply, {chan, opts}}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, {chan, _opts}) do
    {:stop, :normal, chan}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, {chan, opts}) do
    {:noreply, {chan, opts}}
  end

  @impl GenServer
  def handle_info(
        {:basic_deliver, payload,
         %{delivery_tag: tag, redelivered: redelivered, routing_key: routing_key}},
        {chan, opts}
      ) do
    spawn(fn ->
      try do
        Basic.ack(chan, tag)
        Apr.Events.consume_incoming_event(opts, payload, routing_key)
      rescue
        exception ->
          # Requeue unless it's a redelivered message.
          # This means we will retry consuming a message once in case of exception
          # before we give up and have it moved to the error queue
          Basic.reject(chan, tag, requeue: not redelivered)
          IO.puts("Error parsing #{payload} #{exception}")
      end
    end)
    {:noreply, {chan, opts}}
  end
end
