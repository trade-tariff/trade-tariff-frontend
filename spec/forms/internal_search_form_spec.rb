require 'spec_helper'

RSpec.describe InternalSearchForm, type: :model do
  describe 'query validations' do
    context 'with a valid query' do
      subject(:form) { described_class.new(q: 'horse') }

      it { is_expected.to be_valid }
    end

    context 'when query is blank' do
      subject(:form) { described_class.new(q: '') }

      before { form.valid? }

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:q]).to include('Enter a search term') }
    end

    context 'when query is too short' do
      subject(:form) { described_class.new(q: 'a') }

      it { is_expected.not_to be_valid }
    end

    context 'when query is at minimum length' do
      subject(:form) { described_class.new(q: 'ab') }

      it { is_expected.to be_valid }
    end

    context 'when query exceeds maximum length' do
      subject(:form) { described_class.new(q: 'a' * 150) }

      it 'truncates to 100 characters' do
        expect(form.q.length).to eq(100)
      end

      it { is_expected.to be_valid }
    end
  end

  describe 'query sanitisation' do
    it 'strips whitespace' do
      expect(described_class.new(q: '  horse  ').q).to eq('horse')
    end

    it 'removes square brackets' do
      expect(described_class.new(q: '[horse]').q).to eq('horse')
    end

    it 'strips and removes brackets together' do
      expect(described_class.new(q: '  [leather] bag  ').q).to eq('leather bag')
    end

    it 'truncates to 100 characters' do
      expect(described_class.new(q: 'x' * 200).q.length).to eq(100)
    end
  end

  describe 'answer validation' do
    context 'without :answer context' do
      subject(:form) { described_class.new(q: 'horse') }

      it 'does not validate answer presence' do
        expect(form).to be_valid
      end
    end

    context 'with :answer context' do
      it 'is invalid when answer is blank' do
        form = described_class.new(q: 'horse')
        form.valid?(:answer)

        expect(form.errors[:answer]).to include('Select an option')
      end

      it 'is valid when answer is present' do
        form = described_class.new(q: 'horse', answer: 'Racing')
        expect(form).to be_valid(:answer)
      end
    end
  end
end
