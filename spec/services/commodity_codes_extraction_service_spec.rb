require 'spec_helper'

RSpec.describe CommodityCodesExtractionService do
  subject(:result) { described_class.new(file).call }

  describe '#call' do
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

    context 'when CSV values are decimal-suffixed numeric strings' do
      let(:file) { instance_double(ActionDispatch::Http::UploadedFile, content_type: 'text/csv', read: "1023456789.0\n") }

      it { is_expected.to be_success }
      it { expect(result.codes).to eq(%w[1023456789]) }
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

    context 'when Excel file has commodity codes in the wrong column' do
      let(:file) do
        fixture_file_upload(
          'myott/mycommodities_files/wrong_column_excel_file.xlsx',
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        )
      end

      it { is_expected.not_to be_success }
      it { expect(result.codes).to eq([]) }
      it { expect(result.error_message).to eq('Selected file has no valid commodity codes in column A') }
    end

    context 'when Excel cell values are integer-like floats' do
      let(:file) { instance_double(ActionDispatch::Http::UploadedFile, content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }
      let(:sheet) { instance_double(Roo::Excelx::Sheet) }
      let(:spreadsheet) { instance_double(Roo::Excelx) }

      before do
        allow(Roo::Spreadsheet).to receive(:open).with(file).and_return(spreadsheet)
        allow(spreadsheet).to receive(:sheet).with(0).and_return(sheet)
        allow(sheet).to receive(:last_row).and_return(1)
        allow(sheet).to receive(:column).with('A').and_return([1_023_456_789.0])
      end

      it { is_expected.to be_success }
      it { expect(result.codes).to eq(%w[1023456789]) }
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
