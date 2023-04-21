require 'spec_helper'

RSpec.describe 'commodities/_commodity', type: :view do
  subject(:rendered_page) do
    render 'commodities/commodity', commodity:, initial_indent: 1
    rendered
  end

  let(:commodity) { build :commodity }

  context 'when the commodity has children' do
    let(:commodity) { build(:heading, :with_subheading_and_commodity, producline_suffix:).commodities.first }

    context 'with producline_suffix of 80' do
      let(:producline_suffix) { '80' }

      it 'will show the commodity code' do
        expect(rendered_page).to have_css \
          'li.has_children > .sub_heading_commodity_code_block .segmented-commodity-code'
      end

      it 'shows the children with their codes' do
        expect(rendered_page).to have_css \
          'li.has_children ul.govuk-list > li .commodity__info .segmented-commodity-code',
          count: 1
      end
    end

    context 'with producline_suffix of 10' do
      let(:producline_suffix) { '10' }

      it { is_expected.to have_css 'li.has_children > .sub_heading_commodity_code_block' }

      it 'will not show the commodity code' do
        expect(rendered_page).not_to have_css \
          'li.has_children > .sub_heading_commodity_code_block .segmented-commodity-code'
      end

      it 'shows the children with their codes' do
        expect(rendered_page).to have_css \
          'li.has_children ul.govuk-list > li .commodity__info .segmented-commodity-code',
          count: 1
      end
    end
  end

  context 'when the commodity does not have children' do
    let(:commodity) { build :commodity }

    it { is_expected.to have_css 'li .commodity__info .segmented-commodity-code' }
    it { is_expected.not_to have_css 'li.has_children' }
  end
end
