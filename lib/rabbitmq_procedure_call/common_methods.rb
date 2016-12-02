module RabbitmqProcedureCall
  TimeoutError = Class.new(StandardError)

  module CommonMethods
    def serialize(data)
      JSON.dump data
    end

    def unserialize(raw_data)
      JSON.parse raw_data
    end

    def exchange_name
      'rabbitmq-procedure-call'
    end

    def make_exchange
      @exchange = @channel.direct exchange_name,
                                  durable: true
    end
  end
end
