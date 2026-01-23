class CommodityCodesExtractionService
  Result = Struct.new(:success?, :codes, :error_message)

  VALID_FILE_TYPES = [
    'text/csv',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  ].freeze

  def initialize(file)
    @file = file
  end

  def call
    return Result.new(false, [], 'Please upload a file using the Choose file button or drag and drop.') if @file.blank?

    unless VALID_FILE_TYPES.include?(@file.content_type)
      return Result.new(false, [], 'Please upload a csv/excel file')
    end

    codes = extract_codes_from_file(@file)

    if codes.blank?
      return Result.new(false, [], 'No commodities uploaded, please ensure valid commodity codes are in column A')
    end

    Result.new(true, codes, nil)
  end

  private

  def extract_codes_from_file(file)
    rows =
      case file.content_type
      when 'text/csv'
        CSV.parse(file.read).map { |row| row[0] }
      else
        sheet = Roo::Spreadsheet.open(file).sheet(0)
        sheet.last_row ? sheet.map { |row| row[0] } : []
      end

    rows.filter_map do |value|
      code = value.to_s.gsub(/[^0-9]/, '')
      code if code.present? && code.length.between?(1, 20)
    end
  end
end
