require 'spec_helper'

RSpec.describe StepsHelper, type: :helper do
  describe '#back_link' do
    before do
      allow(helper).to receive(:wizard).and_return(wizard)
    end

    let(:wizard) do
      instance_double(
        'MeursingLookup::Wizard',
        previous_key: previous_key,
      )
    end

    context 'when the wizard has a previous_key' do
      let(:previous_key) { 'starch' }

      it { expect(helper.back_link).to eq('<a class="govuk-back-link" href="/meursing_lookup/steps/starch">Back</a>') }
    end

    context 'when the wizard does not have a previous_key' do
      let(:previous_key) { nil }

      it { expect(helper.back_link).to be_nil }
    end
  end

  describe '#last_commodity_code' do
    before { session[:commodity_code] = commodity_code }

    let(:commodity_code) { 'foo' }

    it { expect(helper.last_commodity_code).to eq('foo') }
  end
end
