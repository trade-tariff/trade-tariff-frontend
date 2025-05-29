RSpec.describe AdditionalDutyApplicableMeasuresMerger, :user_session do
  subject(:service) { described_class.new }

  let(:uk_filtered_commodity) { Api::Commodity.build('uk', '0103921100') }
  let(:xi_filtered_commodity) { Api::Commodity.build('xi', '0103921100') }

  describe '#call' do
    before do
      allow(Api::Commodity).to receive(:build).and_call_original
    end

    context 'when on an xi route' do
      let(:user_session) { build(:user_session, commodity_source: 'xi', commodity_code: '0103921100') }

      let(:uk_excise_measures) {}

      let(:expected_measures) do
        xi_filtered_commodity.applicable_measures.select(&:applicable?) + uk_filtered_commodity.applicable_excise_measures
      end

      it 'fetches the xi commodity' do
        service.call

        expect(Api::Commodity).to have_received(:build).with(
          'xi',
          '0103921100',
          anything,
        )
      end

      it 'fetches the uk commodity' do
        service.call

        expect(Api::Commodity).to have_received(:build).with(
          'uk',
          '0103921100',
          anything,
        )
      end

      it { expect(service.call).to eql(expected_measures) }
    end

    context 'when on a uk route' do
      let(:user_session) { build(:user_session, commodity_source: 'uk', commodity_code: '0103921100') }

      let(:expected_measures) { uk_filtered_commodity.applicable_measures.select(&:applicable?) }

      it 'does not fetch the xi commodity' do
        service.call

        expect(Api::Commodity).not_to have_received(:build).with(
          'xi',
          '0103921100',
          anything,
        )
      end

      it 'fetches the uk commodity' do
        service.call

        expect(Api::Commodity).to have_received(:build).with(
          'uk',
          '0103921100',
          anything,
        )
      end

      it { expect(service.call).to eql(expected_measures) }
    end
  end
end
