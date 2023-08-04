require 'spec_helper'

RSpec.describe 'measures/_measure_export_eu', type: :view do
  context 'when in EU service' do
    include_context 'with XI service'

    before do
      render 'measures/measures_export_eu',
             declarable: nil,
             uk_declarable: uk_commodity,
             xi_declarable: eu_commodity,
             rules_of_origin_schemes: []
    end

    let(:eu_commodity) { build(:commodity) }

    context 'when there are only EU export measures' do
      let(:eu_commodity) { build(:commodity, :with_export_measures) }
      let(:uk_commodity) { nil }

      it { expect(rendered).to have_css('#eu-export-controls') }

      it { expect(rendered).to have_css('#uk-export-controls') }
      it { expect(rendered).to match('There are no export measures for this commodity on this date.') }
    end

    context 'when there are no export measures for both EU and UK' do
      let(:uk_commodity) { build(:commodity) }
      let(:eu_commodity) { build(:commodity) }

      it { expect(rendered).not_to have_css('h3#uk-export-controls') }
      it { expect(rendered).not_to have_css('h3#eu-export-controls') }

      it { expect(rendered).to match('Export controls') }
      it { expect(rendered).to match('There are no UK or EU export measures for this commodity on this date.') }
    end
  end
end
