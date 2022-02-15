require 'spec_helper'

RSpec.describe Search do
  describe '#date' do
    context 'when the date attributes are supplied' do
      subject(:search) do
        described_class.new(
          'q' => 'foo',
          'day' => '01',
          'month' => '02',
          'year' => '2021',
        )
      end

      it 'calls the legacy TariffDate builder' do
        allow(TariffDate).to receive(:build).and_call_original

        search.date

        expect(TariffDate).to have_received(:build)
      end

      it { expect(search.date).to eq(Date.parse('2021-02-01')) }
    end

    context 'when the legacy as_of parameter is supplied' do
      subject(:search) do
        described_class.new(
          'q' => 'foo',
          'as_of' => '2021-01-01',
        )
      end

      it 'calls the legacy TariffDate builder' do
        allow(TariffDate).to receive(:build_legacy).and_call_original

        search.date

        expect(TariffDate).to have_received(:build_legacy)
      end

      it { expect(search.date).to eq(Date.parse('2021-01-01')) }
    end
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
