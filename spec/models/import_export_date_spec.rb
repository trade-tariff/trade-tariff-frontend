require 'spec_helper'

RSpec.describe ImportExportDate do
  subject(:import_export_date) { described_class.new(attributes) }

  let(:attributes) do
    {
      'import_date(3i)' => '1',    # day
      'import_date(2i)' => '2',    # month
      'import_date(1i)' => '2021', # year
    }
  end

  describe 'valid?' do
    before { import_export_date.valid? }

    context 'when a valid date is passed' do
      let(:attributes) do
        {
          'import_date(3i)' => '1',    # day
          'import_date(2i)' => '2',    # month
          'import_date(1i)' => '2021', # year
        }
      end

      it { expect(import_export_date.errors.messages).to be_empty }
      it { is_expected.to be_valid }
    end

    context 'when a non-date is passed' do
      let(:attributes) do
        {
          'import_date(3i)' => 'foo',  # invalid
          'import_date(2i)' => '1',    # month
          'import_date(1i)' => '2021', # year
        }
      end

      it { expect(import_export_date.errors.messages[:import_date]).to include('Enter a valid date') }
      it { is_expected.not_to be_valid }
    end

    context 'when an invalid date is passed' do
      let(:attributes) do
        {
          'import_date(3i)' => '30',   # invalid
          'import_date(2i)' => '2',    # month
          'import_date(1i)' => '2021', # year
        }
      end

      it { expect(import_export_date.errors.messages[:import_date]).to include('Enter a valid date') }
      it { is_expected.not_to be_valid }
    end

    context 'when an empty date is passed' do
      let(:attributes) do
        {
          'import_date(3i)' => '', # invalid
          'import_date(2i)' => '', # invalid
          'import_date(1i)' => '', # invalid
        }
      end

      it { expect(import_export_date.errors.messages[:import_date]).to include('Enter a valid date') }
      it { is_expected.not_to be_valid }
    end
  end

  describe '#year' do
    it { expect(import_export_date.year).to eq(2021) }
  end

  describe '#month' do
    it { expect(import_export_date.month).to eq(2) }
  end

  describe '#day' do
    it { expect(import_export_date.day).to eq(1) }
  end
end
