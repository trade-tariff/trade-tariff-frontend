require 'spec_helper'

RSpec.describe 'measures/_measures.html.erb', type: :view, vcr: {
  cassette_name: 'geographical_areas#countries',
} do
  subject { render_page && rendered }

  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))

    allow(GeographicalArea).to receive(:find).with('FR').and_return(build(:geographical_area, id: 'FR', description: 'France'))
    allow(search).to receive(:countries).and_return all_countries

    assign :search, search
  end

  let(:search) { Search.new(q: '0101300000') }
  let(:all_countries) { GeographicalArea.all }
  let(:presented_commodity) { CommodityPresenter.new(commodity) }

  let(:commodity) do
    TradeTariffFrontend::ServiceChooser.with_source(:uk) do
      VCR.use_cassette('headings_show_0101_api_json_content_type') do
        Commodity.find('0101300000', {})
      end
    end
  end

  shared_examples 'measures with rules of origin tab' do
    it { is_expected.to have_css '.govuk-tabs .govuk-tabs__tab', count: 4 }
    it { is_expected.to have_css '.govuk-tabs__panel#import', count: 1 }
    it { is_expected.to have_css '.govuk-tabs__panel#export', count: 1 }
    it { is_expected.to have_css '.govuk-tabs__panel#rules-of-origin', count: 1 }
    it { is_expected.to have_css '.govuk-tabs__panel#footnotes', count: 1 }
  end

  context 'with uk service' do
    let :render_page do
      render 'measures/measures',
             declarable: presented_commodity,
             uk_declarable: presented_commodity,
             xi_declarable: nil,
             rules_of_origin_schemes: []
    end

    context 'without country selected' do
      it_behaves_like 'measures with rules of origin tab'
      it { is_expected.to have_css '#rules-of-origin h2', text: 'rules of origin' }
    end

    context 'with country selected' do
      let(:search) { Search.new(q: '0101300000', 'country' => 'FR') }

      it_behaves_like 'measures with rules of origin tab'
      it { is_expected.to have_css '#rules-of-origin h2', text: 'rules of origin for trading' }
    end
  end

  context 'with xi service' do
    let :render_page do
      render 'measures/measures',
             declarable: presented_commodity,
             uk_declarable: presented_commodity,
             xi_declarable: presented_commodity,
             rules_of_origin_schemes: []
    end

    context 'without country selected' do
      it_behaves_like 'measures with rules of origin tab'
      it { is_expected.to have_css '#rules-of-origin h2', text: 'rules of origin' }
    end

    context 'with country selected' do
      let(:search) { Search.new(q: '0101300000', 'country' => 'FR') }

      it_behaves_like 'measures with rules of origin tab'
      it { is_expected.to have_css '#rules-of-origin h2', text: 'rules of origin for trading' }
    end
  end
end
