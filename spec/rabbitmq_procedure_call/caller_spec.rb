require 'spec_helper'

RSpec.describe RabbitmqProcedureCall::Caller do
  describe '#initialize' do
    let(:method_name) { 'say_hello' }
    let(:default_timeout) { 4 }
    let(:default_pop_delay) { 0.25 }
    let(:timeout) { 123 }
    let(:pop_delay) { 0.1 }

    context 'with default params' do
      subject { described_class.new(method_name) }
      it { expect(subject.method_name).to eq method_name }
      it { expect(subject.timeout).to eq default_timeout }
      it { expect(subject.pop_delay).to eq default_pop_delay }
    end

    context 'when timeout set' do
      subject { described_class.new(method_name, timeout, pop_delay) }
      it { expect(subject.timeout).to eq timeout }
    end

    context 'when pop delay set' do
      subject { described_class.new(method_name, timeout, pop_delay) }
      it { expect(subject.pop_delay).to eq pop_delay }
    end
  end

  describe '#call' do
    let(:timeout) { 1 }
    subject { described_class.new(method_name, timeout).call(params) }
    let(:method_name) { 'say_hello' }
    let(:params) { { msg: 'foo' } }
    let(:bunny_connection) do
      conn = double(:bunny_connection)
      allow(conn).to receive(:start).and_return(nil)
      allow(conn).to receive(:close).and_return(nil)
      conn
    end
    let(:channel) do
      ch = double(:channel)
      allow(ch).to receive(:close).once
      allow(ch).to receive(:queue)
        .with(instance_of(String), exclusive: true)
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
    let(:delivery_info) do
      {}
    end
    let(:props) do
      {}
    end
    let(:body) do
      JSON.dump(msg: 'foo')
    end
    let(:queue) do
      q = double(:queue)
      allow(q).to receive(:bind).with(any_args)
      allow(q).to receive(:subscribe)
        .with(auto_ack: true) do |&block|
          block.call(delivery_info, props, body)
        end
      q
    end
    let(:route_name) do
      'response-<uuid>'
    end

    before do
      rng_class = class_double('RabbitmqProcedureCall::RouteNameGenerator')
                  .as_stubbed_const
      expect(rng_class).to receive(:call)
        .with('response')
        .and_return(route_name)

      bunny_class = class_double('Bunny').as_stubbed_const

      allow(bunny_class).to receive(:new).and_return(bunny_connection)

      allow(bunny_connection).to receive(:create_channel)
        .with(no_args)
        .once
        .and_return(channel)

      headers = { reply_to: route_name }
      allow(exchange).to receive(:publish).with JSON.dump(params),
                                                headers: headers,
                                                routing_key: method_name
    end

    context 'with valid response' do
      before do
        allow(queue).to receive(:pop).and_return([nil, nil, body])
      end

      it 'calls publish message' do
        headers = { reply_to: route_name }
        expect(exchange).to receive(:publish).with JSON.dump(params),
                                                   headers: headers,
                                                   routing_key: method_name
        subject
      end

      it 'receives response and process it' do
        expect(queue).to receive(:pop).once.and_return([nil, nil, body])
        subject
      end
    end

    context 'with invalid response' do
      it 'raise timeout error' do
        expect(queue).to receive(:pop)
          .at_least(:once)
          .and_return([nil, nil, nil])
        expect { subject }.to raise_error(RabbitmqProcedureCall::TimeoutError)
      end
    end
  end
end
