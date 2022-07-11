require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::Base do
  subject(:instance) { mock_step.new wizard, wizardstore }

  include_context 'with rules of origin store'

  let :mock_step do
    Class.new(described_class) {}
  end

  let :wizard do
    RulesOfOrigin::Wizard.new wizardstore,
                              RulesOfOrigin::Wizard.steps.first.key
  end

  it { is_expected.to have_attributes service: 'uk' }
  it { is_expected.to have_attributes service_country_name: 'the UK' }
  it { is_expected.to have_attributes trade_country_name: country.description }
  it { is_expected.to have_attributes commodity_code: wizardstore['commodity_code'] }
  it { is_expected.to have_attributes chosen_scheme: schemes.first }

  describe 'scheme_title' do
    subject { instance.scheme_title }

    it { is_expected.to eql schemes.first.title }

    context 'with multiple schemes' do
      include_context 'with rules of origin store', :importing, scheme_count: 2,
                                                                chosen_scheme: 2

      it { is_expected.to eql schemes.second.title }
    end
  end
end
