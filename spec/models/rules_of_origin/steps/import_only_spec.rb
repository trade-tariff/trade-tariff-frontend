require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::ImportOnly do
  include_context 'with rules of origin store', :with_chosen_scheme
  include_context 'with wizard step', RulesOfOrigin::Wizard

  let :schemes do
    build_list :rules_of_origin_scheme, 2, countries: [country.id],
                                           unilateral: true
  end

  it { is_expected.to respond_to :import_only }

  it { is_expected.to have_attributes commodity_code: wizardstore['commodity_code'] }
  it { is_expected.to have_attributes trade_country_name: country.description }

  describe '#skipped?' do
    subject { instance.skipped? }

    it { is_expected.to be false }

    context 'with non GSP selected' do
      let(:schemes) { build_list :rules_of_origin_scheme, 2, unilateral: false }

      it { is_expected.to be true }
    end
  end
end
