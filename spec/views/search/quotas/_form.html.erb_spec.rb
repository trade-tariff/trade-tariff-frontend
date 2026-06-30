require 'spec_helper'

RSpec.describe 'search/quotas/_form', type: :view do
  subject(:rendered_page) do
    render partial: 'search/quotas/form', locals: { search_form:, section_css: '' }
    rendered
  end

  let(:search_form) { QuotaSearchForm.new({}) }

  before do
    allow(search_form).to receive(:geographical_areas).and_return([])
  end

  it 'keeps flat parameter names and matching label targets', :aggregate_failures do
    expect(rendered_page).to have_css('label[for="order_number"]', text: /quota order number/i)
    expect(rendered_page).to have_css('input#order_number[name="order_number"]')
    expect(rendered_page).to have_css('label[for="goods_nomenclature_item_id"]', text: /commodity code/i)
    expect(rendered_page).to have_css('input#goods_nomenclature_item_id[name="goods_nomenclature_item_id"]')
    expect(rendered_page).to have_css('label[for="geographical_area_id"]', text: /country to which the quota applies/i)
    expect(rendered_page).to have_css('select#geographical_area_id[name="geographical_area_id"]')
    expect(rendered_page).to have_css('label[for="critical"]', text: /critical state/i)
    expect(rendered_page).to have_css('select#critical[name="critical"]')
    expect(rendered_page).to have_css('label[for="status"]', text: 'Status')
    expect(rendered_page).to have_css('select#status[name="status"]')
  end
end
