RSpec.shared_context 'bunny double', shared_context: :metadata do
  before do
    bunny_class = class_double('Bunny').as_stubbed_const
    allow(bunny_class).to receive(:new).and_return(bunny_connection)
  end

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

  let(:exchange) do
    double(:exchange)
  end

  let(:channel) do
    ch = double(:channel)

    allow(ch).to receive(:close).once

    allow(ch).to receive(:queue)
      .with(
        instance_of(String),
        exclusive: true,
        durable: false,
        auto_delete: true
      )
      .once
      .and_return(queue)

    allow(ch).to receive(:direct)
      .with(instance_of(String), durable: true)
      .once
      .and_return(exchange)
    ch
  end
end
