require 'spec_helper'

RSpec.describe 'shared/search/_search_form', type: :view do
  subject(:rendered_form) do
    render partial: 'shared/search/search_form'
    rendered
  end

  before do
    assign(:search, build(:search))
  end

  it 'submits searches with POST' do
    expect(rendered_form).to have_css('form#new_search[method="post"][action="/search"]')
  end
end
