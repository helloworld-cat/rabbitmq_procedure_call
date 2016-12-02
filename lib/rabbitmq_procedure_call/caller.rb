module RabbitmqProcedureCall
  # Caller class
  # example:
  # say_hello = RabbitmqProcedureCall::Caller.new(:say_hello)
  # response = say_hello.call(name: 'World', timeout = 4)
  # puts "-> #{response['msg']}"
  class Caller
    include CommonMethods

    attr_reader :method_name,
                :timeout,
                :pop_delay

    def initialize(method_name, timeout = 4, pop_delay = 0.25)
      @method_name = method_name
      @timeout     = timeout
      @pop_delay   = pop_delay
    end

    def call(params = {})
      @params = params
      open_connection
      generate_reply_route_name
      make_reply_queue
      publish_message # for call remote method
      Timeout.timeout(@timeout) { listen_response }
      @response
    rescue Timeout::Error
      raise TimeoutError, "can't receive response in #{@timeout} seconds"
    ensure
      close_connection
    end

    private

    def listen_response
      loop do
        _delivery_info, _props, body = @queue.pop
        unless body.nil?
          @response = unserialize(body)
          return
        end
        sleep @pop_delay
      end
    end

    def make_reply_queue
      @queue = @channel.queue "queue-#{@reply_route_name}", exclusive: true
      @queue.bind @exchange, routing_key: @reply_route_name
    end

    def open_connection
      @conn = Bunny.new
      @conn.start
      @channel = @conn.create_channel
      make_exchange
    end

    def close_connection
      @channel.close if @channel
      @conn.close    if @conn
    end

    def generate_reply_route_name
      @reply_route_name = RouteNameGenerator.call(prefix = 'response')
    end

    def publish_message
      body = serialize @params
      headers = { reply_to: @reply_route_name }
      @exchange.publish body, headers: headers, routing_key: @method_name
    end
  end
end
