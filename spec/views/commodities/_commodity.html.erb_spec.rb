require 'spec_helper'

RSpec.describe 'commodities/_commodity.html.erb', type: :view do
  subject(:rendered_page) do
    render 'commodities/commodity', commodity: commodity
    rendered
  end

  describe 'for commodity' do
    context 'with children' do
      let(:heading) { build :heading, commodities: [parent, child] }

      let(:parent) do
        attributes_for :commodity, producline_suffix: producline_suffix,
                                   number_indents: 2
      end

      let(:child) do
        attributes_for :commodity, producline_suffix: producline_suffix,
                                   parent_sid: parent[:goods_nomenclature_sid],
                                   number_indents: 3
      end

      let(:commodity) { heading.commodities.first }

      context 'with producline_suffix of 80' do
        let(:producline_suffix) { '80' }

        it 'will show the commodity code' do
          expect(rendered_page).to have_css \
            'li.has_children > .sub_heading_commodity_code_block .commodity-code'
        end

        it 'shows the children with their codes' do
          expect(rendered_page).to have_css \
            'li.has_children ul.govuk-list > li .commodity__info .commodity-code',
            count: 1
        end
      end

      context 'with producline_suffix of 10' do
        let(:producline_suffix) { '10' }

        it { is_expected.to have_css 'li.has_children > .sub_heading_commodity_code_block' }

        it 'will not show the commodity code' do
          expect(rendered_page).not_to have_css \
            'li.has_children > .sub_heading_commodity_code_block .commodity-code'
        end

        it 'shows the children with their codes' do
          expect(rendered_page).to have_css \
            'li.has_children ul.govuk-list > li .commodity__info .commodity-code',
            count: 1
        end
      end
    end

    context 'without children' do
      let(:commodity) { build :commodity }

      it { is_expected.to have_css 'li .commodity__info .commodity-code' }
      it { is_expected.not_to have_css 'li.has_children' }
    end
  end
end
