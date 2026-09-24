require 'spec_helper'

RSpec.describe 'shared/context_tables/_commodity', type: :view, vcr: { cassette_name: 'geographical_areas#it' } do
  subject { render }

  before do
    allow(view).to receive_messages(declarable: declarable, uk_declarable: declarable, xi_declarable: declarable)
    allow(DeclarableUnitService).to receive(:new).and_return(instance_double(DeclarableUnitService, call: 'There are no supplementary unit measures assigned to this commodity'))
    assign(:search, search)
  end

  let(:declarable) { build(:commodity) }
  let(:search) { build(:search, :with_search_date, :with_country) }

  context 'with an import-only supplementary measure' do
    include_context 'with UK service'

    before do
      allow(DeclarableUnitService).to receive(:new).and_call_original
    end

    let(:declarable) do
      build(:commodity, import_measures: [
        attributes_for(
          :measure,
          :import_only_supplementary,
          :erga_omnes,
          :with_supplementary_measure_components,
        ),
      ])
    end

    it { is_expected.to have_css 'dt', exact_text: 'Supplementary unit (import)' }
    it { is_expected.to have_css 'dd', text: 'Number of items (p/st)' }
  end

  describe 'classification row' do
    it { is_expected.to have_css 'dl div dt', text: 'Classification' }
    it { is_expected.to have_css 'dl div dd', text: declarable.formatted_description }

    context 'when the declarable description is `Other`' do
      let(:declarable) do
        build(
          :commodity,
          :with_ancestors,
          formatted_description: 'Other',
        )
      end

      it { is_expected.to have_css 'dl div dd', text: 'Horses' }
      it { is_expected.to have_css 'dl div dd strong', text: 'Other' }
    end
  end

  describe 'supplementary unit row' do
    it { is_expected.to have_css 'dl div dt', text: 'Supplementary unit' }
    it { is_expected.to have_css 'dl div dd', text: 'There are no supplementary unit measures assigned to this commodity' }
    it { is_expected.to have_css 'dl .govuk-summary-list__row--no-border', text: 'Supplementary unit' }
  end

  it 'keeps low-value duplicate context out of the summary' do
    expect(rendered).not_to have_css 'dt', text: /Commodity|Date of trade/
  end
end
