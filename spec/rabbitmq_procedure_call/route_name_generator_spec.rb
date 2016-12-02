require 'spec_helper'

RSpec.describe RabbitmqProcedureCall::RouteNameGenerator do
  describe '.call' do
    let(:uuid) { '<some-uuid>' }
    before do
      class_double('SecureRandom', uuid: uuid).as_stubbed_const
    end

    context 'without prefix' do
      subject { described_class.call }
      it { expect(subject).to eq(uuid) }
    end

    context 'with prefix' do
      subject { described_class.call(prefix) }
      let(:prefix) { '<prefix>' }
      it { expect(subject).to eq("#{prefix}-#{uuid}") }
    end
  end
end
