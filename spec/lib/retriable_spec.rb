require 'spec_helper'

RSpec.describe Retriable do
  subject(:call) {}

  describe('#with_retries') do
    let(:cat) { double }

    it 'makes the call' do
      allow(cat).to receive(:maow)

      RetryTest.new.with_retries { cat.maow }

      expect(cat).to have_received(:maow).once
    end

    context 'when unsuccessfull calls' do
      it 'retries multiple times' do
        allow(cat).to receive(:maow)

        expect {
          RetryTest.new.with_retries do
            cat.maow
            raise('error!') # <- StandardError
          end
        }.to raise_error('error!')

        expect(cat).to have_received(:maow).exactly(6).time
      end
    end
  end
end

class RetryTest
  include Retriable
end
