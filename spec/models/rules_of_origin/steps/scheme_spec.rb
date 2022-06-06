require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::Scheme do
  include_context 'with rules of origin store'
  include_context 'with wizard step', RulesOfOrigin::Wizard

  let :schemes do
    build_pair :rules_of_origin_scheme, countries: [country.id]
  end

  it { is_expected.to respond_to :scheme_code }

  describe '#scheme_codes' do
    subject { instance.scheme_codes }

    it { is_expected.to eql schemes.map(&:scheme_code) }
  end

  describe 'validations' do
    subject { instance.tap(&:validate).errors[:scheme_code] }

    context 'with code from list' do
      before { instance.scheme_code = schemes.last.scheme_code }

      it { is_expected.to be_empty }
    end

    context 'with unknown code' do
      before { instance.scheme_code = 'RANDOM' }

      it { is_expected.to include 'Select an agreement' }
    end

    context 'with no code' do
      before { instance.scheme_code = nil }

      it { is_expected.to include 'Select an agreement' }
    end
  end
end
