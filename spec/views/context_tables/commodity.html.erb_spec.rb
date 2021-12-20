require 'spec_helper'

RSpec.describe 'shared/context_tables/_commodity.html.erb', type: :view, vcr: { cassette_name: 'geographical_areas#it' } do
  subject { render }

  before do
    assign(:commodity, commodity)
    assign(:search, search)
  end

  let(:commodity) { build(:commodity) }
  let(:search) { Search.new(as_of: Time.zone.today.iso8601, country: 'IT') }

  describe 'commodity row' do
    it { is_expected.to have_css 'dl div dt', text: 'Commodity' }
    it { is_expected.to have_css 'dl div dd', text: '0101300000' }
  end

  describe 'classification row' do
    it { is_expected.to have_css 'dl div dt', text: 'Classification' }
    it { is_expected.to have_css 'dl div dd', text: commodity.formatted_description }
  end

  describe 'supplementary unit row' do
    it { is_expected.to have_css 'dl div dt', text: 'Supplementary unit' }
    it { is_expected.to have_css 'dl div dd', text: 'No supplementary unit required.' }
  end

  describe 'date of trade row' do
    it { is_expected.to have_css 'dl div dt', text: 'Date of trade' }
    it { is_expected.to have_css 'dl div dd', text: Time.zone.today.to_formatted_s(:long) }
  end

  describe 'trading partner row' do
    it { is_expected.to have_css 'dl div dt', text: 'Filter by country' }
    it { is_expected.to have_css 'dl div dd', text: 'Italy' }
  end
end
