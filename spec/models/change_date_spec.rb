require 'spec_helper'

RSpec.describe ChangeDate do
  subject(:change_date) { described_class.new(attributes) }

  let(:attributes) do
    {
      'import_date(3i)' => '1',    # day
      'import_date(2i)' => '2',    # month
      'import_date(1i)' => '2021', # year
    }
  end

  describe 'errors' do
    context 'when a valid date is passed' do
      let(:attributes) do
        {
          'import_date(3i)' => '1',    # day
          'import_date(2i)' => '2',    # month
          'import_date(1i)' => '2021', # year
        }
      end

      it { expect(change_date.errors.messages).to be_empty }
    end

    context 'when an invalid date is passed' do
      let(:attributes) do
        {
          'import_date(3i)' => 'foo',  # day
          'import_date(2i)' => '1',    # month
          'import_date(1i)' => '2021', # year
        }
      end

      it { expect(change_date.errors.messages[:import_date]).to include('Enter a valid date') }
    end
  end

  describe '#year' do
    it { expect(change_date.year).to eq(2021) }
  end

  describe '#month' do
    it { expect(change_date.month).to eq(2) }
  end

  describe '#day' do
    it { expect(change_date.day).to eq(1) }
  end
end
