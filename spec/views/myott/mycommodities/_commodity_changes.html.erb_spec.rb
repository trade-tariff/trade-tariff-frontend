require 'spec_helper'

RSpec.describe 'myott/mycommodities/_commodity_changes.html.erb', type: :view do
  let(:change) do
    build(:commodity_change, description: 'test description', count: 10)
  end

  before do
    assign(:commodity_change, [change])
    allow(view).to receive(:as_of).and_return(Date.new(2025, 11, 21))
    render partial: 'myott/mycommodities/commodity_changes', locals: { changes: [change] }
  end

  it 'renders the description' do
    expect(rendered).to match(/test description/)
  end

  it 'renders the count' do
    expect(rendered).to match(/10/)
  end
end
