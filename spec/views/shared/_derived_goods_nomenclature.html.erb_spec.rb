require 'spec_helper'

RSpec.describe 'shared/_derived_goods_nomenclature', type: :view  do
  subject(:rendered_page) { render_page && rendered }

  let :render_page do
    render 'shared/derived_goods_nomenclature', deriving_goods_nomenclatures:
  end

  context 'with 1 item in deriving goods nomanclature array' do
    let(:deriving_goods_nomenclatures) { build_list :goods_nomenclature, 1 }

    it { is_expected.to have_css 'p', text: /Goods previously classified under/ }

    it { is_expected.to have_css 'p', text: deriving_goods_nomenclatures.first.goods_nomenclature_item_id }

    it { is_expected.to have_css 'p', text: deriving_goods_nomenclatures.first.formatted_description }

    it { is_expected.to have_css 'p', text: deriving_goods_nomenclatures.first.validity_end_date }
  end

  context 'with more than 1 item in deriving goods nomanclature array' do
    let(:deriving_goods_nomenclatures) { build_list :goods_nomenclature, 2 }

    it { is_expected.to have_css 'table' }

    it { is_expected.to have_css 'p', text: /Goods previously classified under/ }

    it { is_expected.to have_css 'td', text: deriving_goods_nomenclatures.first.goods_nomenclature_item_id }

    it { is_expected.to have_css 'td', text: deriving_goods_nomenclatures.first.formatted_description }

    it { is_expected.to have_css 'td', text: deriving_goods_nomenclatures.first.validity_end_date }

    it { is_expected.to have_css 'td', text: deriving_goods_nomenclatures.last.validity_end_date }
  end
end