RSpec.describe DutyCalculator::ExciseHelper do
  describe '#excise_hint' do
    subject(:excise_hint) { helper.excise_hint }

    it { is_expected.to be_html_safe }
    it { is_expected.not_to match(/SBR/) }
    it { is_expected.to include('https://www.gov.uk/government/publications/uk-trade-tariff-excise-duties-reliefs-drawbacks-and-allowances/uk-trade-tariff-excise-duties-reliefs-drawbacks-and-allowances') }
  end
end
