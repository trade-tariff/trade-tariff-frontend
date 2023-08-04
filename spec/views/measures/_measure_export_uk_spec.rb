require 'spec_helper'

RSpec.describe 'measures/_measure_export_uk', type: :view do
  context 'when in UK service' do
    include_context 'with UK service'

    before do
      render 'measures/measures_export_uk',
             declarable: nil,
             uk_declarable: commodity,
             xi_declarable: nil,
             rules_of_origin_schemes: []
    end

    context 'when there are UK export measures' do
      let(:commodity) { build(:commodity, :with_export_measures) }

      it { expect(rendered).to have_css('h3#uk-export-controls') }
    end

    context 'when there are no export measures' do
      let(:commodity) { build(:commodity) }

      it { expect(rendered).to match('There are no export measures for this commodity on this date.') }
    end
  end
end
