require 'spec_helper'

RSpec.describe 'shared/context_tables/_commodity', type: :view, vcr: { cassette_name: 'geographical_areas#it' } do
  subject { render }

  before do
    allow(view).to receive(:declarable).and_return(declarable)
    assign(:search, search)
  end

  let(:declarable) { build(:commodity) }
  let(:search) { build(:search, :with_search_date, :with_country) }

  describe 'commodity row' do
    it { is_expected.to have_css 'dl div dt', text: 'Commodity' }
    it { is_expected.to have_css 'dl div dd', text: declarable.goods_nomenclature_item_id }
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

  describe 'validity dates row' do
    it { is_expected.to have_css 'dl div dt', text: 'Commodity valid from' }
    it { is_expected.to have_css 'dl div dd', text: "#{declarable.validity_start_date.to_formatted_s(:long)}" }
  end

  describe 'supplementary unit row' do
    it { is_expected.to have_css 'dl div dt', text: 'Supplementary unit' }
    it { is_expected.to have_css 'dl div dd', text: 'There are no supplementary unit measures assigned to this commodity' }
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
