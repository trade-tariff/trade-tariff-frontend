require 'spec_helper'

RSpec.describe 'a-z index', vcr: { cassette_name: 'search_references#az_index' } do
  before do
    visit a_z_index_path('a')
  end

  it { expect(page).to have_content('A2 paper') }
end
