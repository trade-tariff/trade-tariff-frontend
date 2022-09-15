require 'spec_helper'

RSpec.describe Retriable do
  subject(:call) {}

  describe('#with_retries') do
    let(:cat) { double }

    it 'makes the call' do
      allow(cat).to receive(:meow)

      RetryTest.new.with_retries { cat.meow }

      expect(cat).to have_received(:meow).once
    end

    context 'when unsuccessfull calls' do
      it 'retries multiple times' do
        allow(cat).to receive(:meow)

        expect {
          RetryTest.new.with_retries do
            cat.meow
            raise('error!') # <- StandardError
          end
        }.to raise_error('error!')

        expect(cat).to have_received(:meow).exactly(6).time
      end
    end
  end
end

class RetryTest
  include Retriable
end
