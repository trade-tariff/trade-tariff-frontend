RSpec.describe NumberWithHighPrecisionFormatter do
  subject(:formatter) { described_class.new(number) }

  context 'with an integer number' do
    let(:number) { 120 }

    describe '#call' do
      it 'formats the number with two decimals' do
        expect(formatter.call).to eq('120.00')
      end
    end
  end

  context 'with a number with one decimal digit' do
    let(:number) { 120.1 }

    describe '#call' do
      it 'formats the number with two decimals' do
        expect(formatter.call).to eq('120.10')
      end
    end
  end

  context 'with a number with two decimal digit' do
    let(:number) { 120.12 }

    describe '#call' do
      it 'formats the number with two decimals' do
        expect(formatter.call).to eq('120.12')
      end
    end
  end

  context 'with a number with more than two decimal digit' do
    let(:number) { 120.12400 }

    describe '#call' do
      it 'formats the number with its original amount of significant decimals' do
        expect(formatter.call).to eq('120.124')
      end
    end
  end

  context 'with a number that would normally use scientific notation' do
    let(:number) { 0.000001 }

    describe '#call' do
      it 'formats the number with its original amount of significant decimals' do
        expect(formatter.call).to eq('0.000001')
      end
    end
  end
end
