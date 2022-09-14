require 'spec_helper'

RSpec.describe Retriable do
  subject(:call) {}

  describe('#retries') do
    let(:cat) { double }

    it 'makes the call' do
      allow(cat).to receive(:maow)

      RetryTest.new.retries(StandardError) { cat.maow }

      expect(cat).to have_received(:maow).once
    end

    context 'when unsuccessfull calls' do
      it 'retries multiple times' do
        allow(cat).to receive(:maow)

        expect {
          RetryTest.new.retries(StandardError) do
            cat.maow
            raise('error!') # <- StandardError
          end
        }.to raise_error('error!')

        expect(cat).to have_received(:maow).exactly(6).time
      end
    end
  end
end

require 'retriable'
class RetryTest
  include Retriable
end
