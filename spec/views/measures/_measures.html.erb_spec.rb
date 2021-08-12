require 'spec_helper'

describe 'measures/_measures.html.erb', type: :view do
  subject { rendered }

  before { assign :search, Search.new(q: '0102210000') }

  let(:commodity) do
    TradeTariffFrontend::ServiceChooser.with_source(:uk) do
      VCR.use_cassette('headings_show_0101_api_json_content_type') do
        Commodity.find('0101300000', {})
      end
    end
  end

  let(:presented_commodity) { CommodityPresenter.new(commodity) }

  context 'with uk service' do
    before do
      render 'measures/measures',
             declarable: presented_commodity,
             uk_declarable: presented_commodity,
             xi_declarable: nil
    end

    it { is_expected.to have_css '.govuk-tabs .govuk-tabs__tab', count: 4 }
    it { is_expected.to have_css '.govuk-tabs__panel#overview', count: 1 }
    it { is_expected.to have_css '.govuk-tabs__panel#import', count: 1 }
    it { is_expected.to have_css '.govuk-tabs__panel#export', count: 1 }
    it { is_expected.to have_css '.govuk-tabs__panel#footnotes', count: 1 }
  end

  context 'with xi service' do
    before do
      render 'measures/measures',
             declarable: presented_commodity,
             uk_declarable: presented_commodity,
             xi_declarable: presented_commodity
    end

    it { is_expected.to have_css '.govuk-tabs .govuk-tabs__tab', count: 4 }
    it { is_expected.to have_css '.govuk-tabs__panel#overview', count: 1 }
    it { is_expected.to have_css '.govuk-tabs__panel#import', count: 1 }
    it { is_expected.to have_css '.govuk-tabs__panel#export', count: 1 }
    it { is_expected.to have_css '.govuk-tabs__panel#footnotes', count: 1 }
  end
end
