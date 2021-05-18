require 'spec_helper'

describe CommoditiesHelper, type: :helper do
  describe '#commodity_code' do
    before do
      assign(:heading, heading)
      assign(:commodity, commodity)
    end

    let(:heading) { nil }
    let(:commodity) { nil }

    context 'when the heading is set' do
      let(:heading) { instance_double('Heading', code: '1245000000') }

      it 'returns the correct commodity code' do
        expect(helper.commodity_code).to eq('1245000000')
      end
    end

    context 'when the commodity is set' do
      let(:commodity) { instance_double('Commodity', code: '0987654321') }

      it 'returns the correct commodity code' do
        expect(helper.commodity_code).to eq('0987654321')
      end
    end
  end
end
