require 'spec_helper'

RSpec.describe RabbitmqProcedureCall::CommonMethods do
  include RabbitmqProcedureCall::CommonMethods

  describe '#serialize' do
    let(:data) { { foo: 'bar', number: 123 } }
    subject { serialize(data) }

    it { expect(subject).to be_a String }
  end

  describe '#unserialize' do
    let(:serialized_data) { '{"foo": "bar", "number": 123}' }
    subject { unserialize(serialized_data) }

    it { expect(subject).to be_a Hash }
    it { expect(subject['foo']).to eq('bar') }
    it { expect(subject['number']).to eq(123) }
  end

  describe '#exchange_name' do
    it { expect(exchange_name).to_not be_nil }
  end

  describe '#make_exchange' do
    let(:exchange_name) { 'rabbitmq-procedure-call' }
    it do
      @channel = double(:exchange)
      expect(@channel).to receive(:direct).with(exchange_name, durable: true)
      expect { make_exchange }.to_not raise_error
    end
  end
end
