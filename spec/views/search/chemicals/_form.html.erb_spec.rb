require 'spec_helper'

RSpec.describe 'search/chemicals/_form', type: :view do
  subject(:rendered_page) do
    render partial: 'search/chemicals/form', locals: { search_form: ChemicalSearchForm.new({}), section_css: '' }
    rendered
  end

  it 'keeps flat parameter names and matching label targets', :aggregate_failures do
    expect(rendered_page).to have_css('label[for="cas"]', text: 'CAS number')
    expect(rendered_page).to have_css('input#cas[name="cas"]')
    expect(rendered_page).to have_css('label[for="name"]', text: 'Chemical name')
    expect(rendered_page).to have_css('input#name[name="name"]')
  end
end
