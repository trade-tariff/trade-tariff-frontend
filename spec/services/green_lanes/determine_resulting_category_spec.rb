RSpec.describe ::GreenLanes::DetermineResultingCategory do
  describe '#call' do
    subject(:call) { described_class.new(categories, cat_1_exempt, cat_2_exempt).call }

    let(:categories) { [] }
    let(:cat_1_exempt) { 'false' }
    let(:cat_2_exempt) { 'false' }

    context 'when only category 1' do
      let(:categories) { [1] }

      it { is_expected.to eq(1) }
    end

    context 'when only category 2' do
      let(:categories) { [2] }

      it { is_expected.to eq(2) }
    end

    context 'when only category 3' do
      let(:categories) { [3] }

      it { is_expected.to eq(3) }
    end

    context 'when category 1, 2 and 3' do
      let(:categories) { [1, 2, 3] }

      context 'with both categories are exempt' do
        let(:cat_1_exempt) { 'true' }
        let(:cat_2_exempt) { 'true' }

        it { is_expected.to eq(3) }
      end

      context 'with only category 1 is exempt' do
        let(:cat_1_exempt) { 'true' }

        it { is_expected.to eq(2) }
      end

      # Impossible scenario
      context 'with only category 2 is exempt' do
        let(:cat_2_exempt) { 'true' }

        it { is_expected.to eq(1) }
      end

      context 'with no categories are exempt' do
        it { is_expected.to eq(1) }
      end
    end

    context 'when category 1 and 2' do
      let(:categories) { [1, 2] }

      context 'with category 1 is exempt' do
        let(:cat_1_exempt) { 'true' }

        it { is_expected.to eq(2) }
      end

      context 'with no categories are exempt' do
        it { is_expected.to eq(1) }
      end
    end

    context 'when category 1 and 3' do
      let(:categories) { [1, 3] }

      context 'with category 1 is exempt' do
        let(:cat_1_exempt) { 'true' }

        it { is_expected.to eq(3) }
      end

      context 'with no categories are exempt' do
        it { is_expected.to eq(1) }
      end
    end

    context 'when category 2 and 3' do
      let(:categories) { [2, 3] }

      context 'with category 2 is exempt' do
        let(:cat_2_exempt) { 'true' }

        it { is_expected.to eq(3) }
      end

      context 'with no categories are exempt' do
        it { is_expected.to eq(2) }
      end
    end

    context 'when no categories are selected' do
      it { expect { call }.to raise_error(ArgumentError, 'Impossible to determine your result') }
    end
  end
end
