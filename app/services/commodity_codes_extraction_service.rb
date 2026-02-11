class CommodityCodesExtractionService
  Result = Struct.new(:success?, :codes, :error_message)
  COMMODITY_CODES_COLUMN = 'A'.freeze

  def initialize(file)
    @file = file
  end

  def call
    codes = extract_codes_from_file(@file)

    if codes.blank?
      return Result.new(false, [], "Selected file has no valid commodity codes in column #{COMMODITY_CODES_COLUMN}")
    end

    Result.new(true, codes, nil)
  end

  private

  def extract_codes_from_file(file)
    rows =
      case file.content_type
      when 'text/csv'
        file.read.lines.map { |line| line.split(',').first&.strip }
      else
        sheet = Roo::Spreadsheet.open(file).sheet(0)
        sheet.last_row.present? ? sheet.column(COMMODITY_CODES_COLUMN).compact : []
      end

    rows.filter_map do |value|
      code = value.to_s.gsub(/[^0-9]/, '')
      code if code.present? && code.length.between?(1, 20)
    end
  end
end
