module RabbitmqProcedureCall
  class Procedure
    include CommonMethods

    attr_reader :params

    def initialize(method_name, proc = nil)
      @method_name = method_name
      @proc        = proc
    end

    def close
      @channel.close if @channel
      @conn.close if @conn
    end

    def start
      setup_conn
      @queue.subscribe(block: true) do |_delivery_info, props, body|
        @reply_to = props[:headers]['reply_to']
        @params   = unserialize body

        if @proc.nil?
          perform(params)
        else
          instance_eval(&@proc)
        end
      end
    ensure
      close
    end

    def respond(params)
      response_body = serialize params
      @exchange.publish response_body, routing_key: @reply_to
    end

    def self.define(method_name, &block)
      procedure = Procedure.new(method_name, block)
      procedure.start
    end

    private

    def procedure_queue_name
      "queue-#{@method_name}".tr('_', '-')
    end

    def perform(_params = {})
      raise NotImplementedError
    end

    def setup_conn
      @conn ||= Bunny.new
      @conn.start
      @channel = @conn.create_channel
      make_exchange
      make_procedure_queue
    end

    def make_procedure_queue
      @queue_name = procedure_queue_name
      @queue      = @channel.queue @queue_name,
                                   exclusive:   true,
                                   durable:     false,
                                   auto_delete: true
      @queue.bind @exchange, routing_key: @method_name
    end
  end
end
