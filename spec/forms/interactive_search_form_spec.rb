require 'spec_helper'

RSpec.describe InteractiveSearchForm, type: :model do
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

    context 'when query is over 100 characters' do
      subject(:form) { described_class.new(q: 'a' * 150) }

      it { is_expected.to be_valid }
    end

    context 'when query is at maximum length' do
      subject(:form) { described_class.new(q: 'a' * 500) }

      it { is_expected.to be_valid }
    end

    context 'when query exceeds maximum length' do
      subject(:form) { described_class.new(q: 'a' * 501) }

      it { is_expected.not_to be_valid }

      it 'adds a length error' do
        form.valid?

        expect(form.errors[:q]).to include('Search term must be 500 characters or fewer')
      end
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

    it 'does not truncate long queries before validation' do
      query = 'x' * 501

      expect(described_class.new(q: query).q).to eq(query)
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
