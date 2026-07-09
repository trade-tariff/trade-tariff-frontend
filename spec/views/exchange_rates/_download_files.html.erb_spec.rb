require 'spec_helper'

RSpec.describe 'exchange_rates/_download_files', type: :view do
  let(:file) { build(:exchange_rate_file) }
  let(:exchange_rate_collection) { build(:exchange_rate_collection) }

  before do
    assign :exchange_rate_collection, exchange_rate_collection
    allow(view).to receive(:files) { [file] }
  end

  it 'renders a download link through the frontend exchange rate file path, not a backend URL' do
    render
    expect(rendered).to have_link('CSV file (2.0 KB)', href: '/exchange_rates/view/files/exrates-monthly-0623.csv')
  end
end
