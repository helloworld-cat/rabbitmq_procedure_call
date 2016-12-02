RSpec.shared_context 'bunny double', shared_context: :metadata do
  before do
    allow(bunny_class).to receive(:new).and_return(bunny_connection)
    allow(rng_class).to receive(:call)
      .with('response')
      .and_return(route_name)
  end

  let(:route_name) { 'response-<uuid>' }
  let(:bunny_class) { class_double('Bunny').as_stubbed_const }
  let(:rng_class) do
    class_double('RabbitmqProcedureCall::RouteNameGenerator').as_stubbed_const
  end

  let(:method_name) { 'say_hello' }
  let(:delivery_info) { Hash.new }
  let(:props) { Hash.new }
  let(:body) { JSON.dump(msg: 'foo') }

  let(:bunny_connection) do
    conn = double(:bunny_connection)
    allow(conn).to receive(:start).and_return(nil)
    allow(conn).to receive(:close).and_return(nil)
    allow(conn).to receive(:create_channel)
      .with(no_args)
      .once
      .and_return(channel)
    conn
  end

  let(:queue) do
    queue = double(:queue)
    allow(queue).to receive(:bind)
      .with(exchange, routing_key: instance_of(String))
    allow(queue).to receive(:pop).and_return([nil, nil, body])
    queue
  end

  let(:channel) do
    ch = double(:channel)
    allow(ch).to receive(:close).once
    allow(ch).to receive(:queue)
      .with(instance_of(String), any_args)
      .once
      .and_return(queue)

    allow(ch).to receive(:direct)
      .with(instance_of(String), durable: true)
      .once
      .and_return(exchange)
    ch
  end

  let(:exchange) do
    double(:exchange)
  end
end
