require 'spec_helper'

RSpec.describe CommodityCodesExtractionService do
  subject(:result) { described_class.new(file).call }

  describe '#call' do
    context 'when file is nil' do
      let(:file) { nil }

      it { is_expected.not_to be_success }
      it { expect(result.codes).to eq([]) }
      it { expect(result.error_message).to eq('Please upload a file using the Choose file button or drag and drop.') }
    end

    context 'when the file type is invalid' do
      let(:file) do
        fixture_file_upload(
          'myott/mycommodities_files/invalid_file_type.txt',
          'text/plain',
        )
      end

      it { is_expected.not_to be_success }
      it { expect(result.codes).to eq([]) }
      it { expect(result.error_message).to eq('Please upload a csv/excel file') }
    end

    context 'when the file is a valid CSV with valid codes' do
      let(:file) do
        fixture_file_upload(
          'myott/mycommodities_files/valid_csv_file.csv',
          'text/csv',
        )
      end

      it { is_expected.to be_success }
      it { expect(result.error_message).to be_nil }
      it { expect(result.codes).not_to be_empty }
      it { expect(result.codes).to all(be_a(String)) }
    end

    context 'when the CSV contains no valid commodity codes' do
      let(:file) do
        fixture_file_upload(
          'myott/mycommodities_files/invalid_csv_file.csv',
          'text/csv',
        )
      end

      it { is_expected.not_to be_success }
      it { expect(result.codes).to eq([]) }
      it { expect(result.error_message).to eq('Selected file has no valid commodity codes in column A') }
    end

    context 'when the file is a valid Excel file with valid codes' do
      let(:file) do
        fixture_file_upload(
          'myott/mycommodities_files/valid_excel_file.xlsx',
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        )
      end

      it { is_expected.to be_success }
      it { expect(result.error_message).to be_nil }
      it { expect(result.codes).not_to be_empty }
      it { expect(result.codes).to all(be_a(String)) }
    end

    context 'when Excel contains no valid commodity codes' do
      let(:file) do
        fixture_file_upload(
          'myott/mycommodities_files/invalid_excel_file.xlsx',
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        )
      end

      it { is_expected.not_to be_success }
      it { expect(result.codes).to eq([]) }
      it { expect(result.error_message).to eq('Selected file has no valid commodity codes in column A') }
    end
  end

  context 'when Excel file is completely empty' do
    let(:file) do
      fixture_file_upload(
        'myott/mycommodities_files/empty_excel_file.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      )
    end

    it { is_expected.not_to be_success }
    it { expect(result.codes).to eq([]) }
    it { expect(result.error_message).to eq('Selected file has no valid commodity codes in column A') }
  end
end
