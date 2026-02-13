require 'spec_helper'

RSpec.describe Myott::UnsubscribeMyCommoditiesForm, type: :model do
  describe 'validations' do
    context 'when decision is blank' do
      subject(:form) { described_class.new(decision: '') }

      before { form.valid? }

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:decision]).to include('Select yes if you want to unsubscribe from your commodity watch list') }
    end

    context 'when decision is nil' do
      subject(:form) { described_class.new(decision: nil) }

      before { form.valid? }

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:decision]).to include('Select yes if you want to unsubscribe from your commodity watch list') }
    end

    context 'when decision is invalid' do
      subject(:form) { described_class.new(decision: 'maybe') }

      before { form.valid? }

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:decision]).to include('Select yes if you want to unsubscribe from your commodity watch list') }
    end

    context 'with a valid decision of true' do
      subject(:form) { described_class.new(decision: 'true') }

      it { is_expected.to be_valid }
    end

    context 'with a valid decision of false' do
      subject(:form) { described_class.new(decision: 'false') }

      it { is_expected.to be_valid }
    end
  end

  describe '#confirmed?' do
    it { expect(described_class.new(decision: 'true').confirmed?).to be true }
    it { expect(described_class.new(decision: 'false').confirmed?).to be false }
    it { expect(described_class.new(decision: nil).confirmed?).to be false }
  end

  describe '#declined?' do
    it { expect(described_class.new(decision: 'false').declined?).to be true }
    it { expect(described_class.new(decision: 'true').declined?).to be false }
    it { expect(described_class.new(decision: nil).declined?).to be false }
  end
end
