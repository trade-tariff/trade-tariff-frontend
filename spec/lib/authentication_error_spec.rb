require 'spec_helper'

RSpec.describe AuthenticationError do
  describe '#initialize' do
    it 'sets the message' do
      error = described_class.new('Authentication failed')

      expect(error.message).to eq('Authentication failed')
    end

    it 'sets the reason when provided' do
      error = described_class.new('Token expired', reason: 'expired')

      expect(error.reason).to eq('expired')
    end

    it 'allows nil reason' do
      error = described_class.new('Authentication failed', reason: nil)

      expect(error.reason).to be_nil
    end
  end

  describe '#expired?' do
    context 'when reason is "expired"' do
      it 'returns true' do
        error = described_class.new('Token expired', reason: 'expired')

        expect(error.expired?).to be true
      end
    end

    context 'when reason is not "expired"' do
      it 'returns false for invalid_token' do
        error = described_class.new('Invalid token', reason: 'invalid_token')

        expect(error.expired?).to be false
      end

      it 'returns false for nil' do
        error = described_class.new('Error', reason: nil)

        expect(error.expired?).to be false
      end
    end
  end

  describe '#should_clear_cookies?' do
    context 'when reason requires cookie clearing' do
      it 'returns true for not_in_group' do
        error = described_class.new('Not in group', reason: 'not_in_group')

        expect(error.should_clear_cookies?).to be true
      end

      it 'returns true for invalid_token' do
        error = described_class.new('Invalid token', reason: 'invalid_token')

        expect(error.should_clear_cookies?).to be true
      end

      it 'returns true for missing_jwks_keys' do
        error = described_class.new('Missing JWKS keys', reason: 'missing_jwks_keys')

        expect(error.should_clear_cookies?).to be true
      end
    end

    context 'when reason does not require cookie clearing' do
      it 'returns false for expired' do
        error = described_class.new('Token expired', reason: 'expired')

        expect(error.should_clear_cookies?).to be false
      end

      it 'returns false for nil' do
        error = described_class.new('Error', reason: nil)

        expect(error.should_clear_cookies?).to be false
      end

      it 'returns false for unknown reason' do
        error = described_class.new('Error', reason: 'unknown_error')

        expect(error.should_clear_cookies?).to be false
      end
    end
  end
end
