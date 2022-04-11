require 'spec_helper'

RSpec.describe MeursingLookupStepsHelper, type: :helper do
  describe '#back_link' do
    before do
      allow(helper).to receive(:wizard).and_return(wizard)
    end

    let(:wizard) do
      instance_double(
        'MeursingLookup::Wizard',
        previous_key:,
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

  describe '#step_with_form?' do
    context 'when the step requires a form' do
      let(:step) { MeursingLookup::Steps::Starch }

      it { expect(helper.step_with_form?(step)).to be(true) }
    end

    context 'when the step does not require a form' do
      let(:step) { MeursingLookup::Steps::Start }

      it { expect(helper.step_with_form?(step)).to be(false) }
    end
  end

  describe '#page_title_for' do
    let(:step) { MeursingLookup::Steps::Start }

    it { expect(helper.page_title_for(step)).to eq('Meursing lookup: start') }
  end
end
