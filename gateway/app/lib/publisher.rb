class Publisher
    class << self

      def publish(exchange, message = {})
        x = channel.fanout("gateway.#{exchange}")
        x.publish(message.to_json)
      end

      def channel
        @channel ||= connection.create_channel
      end

      def connection
        @connection ||= Bunny.new("amqp://guest:guest@rabbitmq:5672").tap(&:start)
      end

    end
end