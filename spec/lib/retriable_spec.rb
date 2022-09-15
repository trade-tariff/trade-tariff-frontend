require 'spec_helper'

RSpec.describe Retriable do
  let :retry_test do
    Class.new do
      include Retriable
    end
  end

  describe('#with_retries') do
    let(:cat) { double(Object, meow: nil) }

    it 'makes the call' do
      retry_test.new.with_retries { cat.meow }

      expect(cat).to have_received(:meow).once
    end

    context 'when unsuccessfull calls' do
      it 'retries multiple times' do
        expect {
          retry_test.new.with_retries do
            cat.meow
            raise(StandardError, 'error!')
          end
        }.to raise_error('error!')

        expect(cat).to have_received(:meow).exactly(6).time
      end
    end
  end
end
