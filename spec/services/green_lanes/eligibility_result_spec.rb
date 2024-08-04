require 'spec_helper'

RSpec.describe ::GreenLanes::EligibilityResult do
  describe '#initialize' do
    it 'normalizes the answers correctly', :aggregate_failures do
      result = described_class.new(
        moving_goods_gb_to_ni: 'yes',
        free_circulation_in_uk: 'no',
        end_consumers_in_uk: 'not_sure',
        ukims: 'yes',
      )

      expect(result.instance_variable_get(:@moving_goods_gb_to_ni)).to be true
      expect(result.instance_variable_get(:@free_circulation_in_uk)).to be false
      expect(result.instance_variable_get(:@end_consumers_in_uk)).to be true
      expect(result.instance_variable_get(:@ukims)).to be true
    end
  end

  describe '#call' do
    subject { described_class.new(params).call }

    context 'when all conditions are met' do
      let(:params) do
        {
          moving_goods_gb_to_ni: 'yes',
          free_circulation_in_uk: 'yes',
          end_consumers_in_uk: 'yes',
          ukims: 'yes',
        }
      end

      it { is_expected.to eq(GreenLanes::EligibilityResult::YOU_MAY_BE_ELIGIBLE) }
    end

    context 'when conditions for not_yet_eligible are met' do
      let(:params) do
        {
          moving_goods_gb_to_ni: 'yes',
          free_circulation_in_uk: 'yes',
          end_consumers_in_uk: 'yes',
          ukims: 'no',
        }
      end

      it { is_expected.to eq(GreenLanes::EligibilityResult::NOT_YET_ELIGIBLE) }
    end

    context 'when any condition for not_eligible is not met' do
      let(:params) do
        {
          moving_goods_gb_to_ni: 'no',
          free_circulation_in_uk: 'yes',
          end_consumers_in_uk: 'yes',
          ukims: 'yes',
        }
      end

      it { is_expected.to eq(GreenLanes::EligibilityResult::NOT_ELIGIBLE) }
    end
  end
end
