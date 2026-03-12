require 'spec_helper'

RSpec.describe BasicSession do
  subject(:basic_session) { described_class.new(password:) }

  before do
    allow(TradeTariffFrontend).to receive(:basic_session_passwords).and_return(passwords)
  end

  let(:passwords) { %w[existing-password uat-password] }

  describe 'validations' do
    context 'with a valid password' do
      let(:password) { 'existing-password' }

      it { is_expected.to be_valid }
    end

    context 'with the second configured password' do
      let(:password) { 'uat-password' }

      it { is_expected.to be_valid }
    end

    context 'with an invalid password' do
      let(:password) { 'wrong-password' }

      it { is_expected.not_to be_valid }
    end

    context 'with a blank password' do
      let(:password) { '' }

      it { is_expected.not_to be_valid }
    end
  end
end
