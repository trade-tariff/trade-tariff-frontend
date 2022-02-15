require 'spec_helper'

RSpec.describe Search do
  describe '#date' do
    subject(:search) { described_class.new('q' => 'foo', 'day' => '01', 'month' => '02', 'year' => '2021') }

    it { expect(search.date).to be_a(TariffDate) }
    it { expect(search.date).to eq(Date.parse('2021-02-01')) }
  end

  it 'strips [ and ] characters from search term' do
    search = described_class.new(q: '[hello] [world]')
    expect(search.q).to eq 'hello world'
  end

  describe 'raises on error if search responds with status 500' do
    let(:api_mock) { double(:api_mock) }
    let(:response_stub) { double(:response_stub, status: 500) }

    before do
      allow(api_mock).to receive(:post).and_return(response_stub)
      allow(described_class).to receive(:api).and_return(api_mock)
    end

    it 'search' do
      expect { described_class.new(q: 'abc').perform }.to raise_error ApiEntity::Error
    end
  end
end
