require 'spec_helper'

RSpec.describe 'shared/context_tables/_chapter', type: :view, vcr: { cassette_name: 'geographical_areas#it' } do
  subject { render }

  before do
    assign(:chapter, chapter)
    assign(:search, search)
  end

  let(:chapter) { build(:chapter) }
  let(:search) { build(:search, :with_search_date, :with_country) }

  describe 'goods nomenclature row' do
    it { is_expected.to have_css 'dl div dt', text: 'Chapter' }
    it { is_expected.to have_css 'dl div dd', text: '01' }
  end

  describe 'classification row' do
    it { is_expected.to have_css 'dl div dt', text: 'Classification' }
    it { is_expected.to have_css 'dl div dd', text: chapter.to_s }
  end

  describe 'supplementary unit row' do
    it { is_expected.not_to have_css 'dl div dt', text: 'Supplementary unit' }
  end

  describe 'date of trade row' do
    it { is_expected.to have_css 'dl div dt', text: 'Date of trade' }
    it { is_expected.to have_css 'dl div dd', text: Time.zone.today.to_formatted_s(:long) }
  end

  describe 'trading partner row' do
    it { is_expected.not_to have_css 'dl div dt', text: 'Filter by country' }
  end
end
