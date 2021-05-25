require 'spec_helper'

describe 'a-z index', vcr: { cassette_name: 'search_references#az_index' } do
  let!(:search_reference) do
    SearchReference.all.first
  end

  before do
    visit a_z_index_path('a')
  end

  it {
    expect(page).to have_content(search_reference.title.titleize.squeeze(' '))
  }
end
