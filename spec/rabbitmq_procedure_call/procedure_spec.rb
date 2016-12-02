require 'spec_helper'

RSpec.describe RabbitmqProcedureCall::Procedure do
  include_context 'bunny double'

  let(:reply_to) { 'respond_queue_name' }
  let(:method_name) { 'say_hello' }
  let(:proc) { double(:proc) }

  let(:delivery_info) do
    {}
  end
  let(:props) do
    {
      headers: { 'reply_to' => reply_to }
    }
  end
  let(:body) do
    JSON.dump(msg: 'foo')
  end

  let(:queue) do
    q = double(:queue)
    allow(q).to receive(:bind).with(exchange, routing_key: method_name)
    allow(q).to receive(:subscribe).and_return nil
    # .with(block: true) do |&block|
    #   block.call(delivery_info, props, body)
    # end
    q
  end

  describe '#initialize' do
    context 'without proc' do
      it { expect { described_class.new(method_name) }.to_not raise_error }
    end
    context 'with proc' do
      it do
        expect { described_class.new(method_name, proc) }.to_not raise_error
      end
    end
  end

  describe '.define' do
    it do
      expect { described_class.define(method_name) }.to_not raise_error
    end
  end
end
