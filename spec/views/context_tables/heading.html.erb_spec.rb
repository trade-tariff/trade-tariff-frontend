require 'spec_helper'

RSpec.describe 'shared/context_tables/_heading', type: :view, vcr: { cassette_name: 'geographical_areas#it' } do
  subject { render }

  before do
    assign(:heading, heading)
    assign(:search, search)
  end

  let(:heading) { build(:heading, declarable:) }
  let(:search) { build(:search, :with_search_date, :with_country) }

  let(:declarable) { true }

  describe 'goods nomenclature row' do
    it { is_expected.to have_css 'dl div dt', text: 'Heading' }
    it { is_expected.to have_css 'dl div dd', text: '0101' }
  end

  describe 'classification row' do
    it { is_expected.to have_css 'dl div dt', text: 'Classification' }
    it { is_expected.to have_css 'dl div dd', text: heading.to_s }
  end

  describe 'date of trade row' do
    it { is_expected.to have_css 'dl div dt', text: 'Date of trade' }
    it { is_expected.to have_css 'dl div dd', text: Time.zone.today.to_formatted_s(:long) }
  end

  context 'when the heading is declarable' do
    let(:declarable) { true }

    describe 'supplementary unit row' do
      it { is_expected.to have_css 'dl div dt', text: 'Supplementary unit' }
      it { is_expected.to have_css 'dl div dd', text: 'No supplementary unit required.' }
    end

    describe 'trading partner row' do
      it { is_expected.to have_css 'dl div dt', text: 'Filter by country' }
      it { is_expected.to have_css 'dl div dd', text: 'Italy' }
    end
  end

  context 'when the heading is not declarable' do
    let(:declarable) { false }

    describe 'supplementary unit row' do
      it { is_expected.not_to have_css 'dl div dt', text: 'Supplementary unit' }
    end

    describe 'trading partner row' do
      it { is_expected.not_to have_css 'dl div dt', text: 'Filter by country' }
    end
  end
end
