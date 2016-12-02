require 'spec_helper'

RSpec.describe RabbitmqProcedureCall::Procedure do
  include_context 'bunny double'

  before do
    allow(queue).to receive(:subscribe).and_return(nil)
  end

  let(:reply_to) { 'respond_queue_name' }
  let(:proc) { double(:proc) }
  let(:props) do
    {
      headers: { 'reply_to' => reply_to }
    }
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
