require 'spec_helper'

RSpec.describe RabbitmqProcedureCall::Caller do
  include_context 'bunny double'

  before do
    allow(queue).to receive(:subscribe).with(block: true) do |&block|
      block.call(delivery_info, props, body)
    end
  end

  describe '#initialize' do
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
    let(:params) { { msg: 'foo' } }

    before do
      allow(exchange).to receive(:publish).with(
        JSON.dump(params),
        headers: { reply_to: route_name },
        routing_key: method_name
      )
    end

    context 'with valid response' do
      it 'calls publish message' do
        expect(exchange).to receive(:publish).with(
          JSON.dump(params),
          headers: { reply_to: route_name },
          routing_key: method_name
        )
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
