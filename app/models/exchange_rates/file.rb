require 'api_entity'

class ExchangeRates::File
  include ApiEntity

  attr_accessor :file_path,
                :file_size, # in bytes
                :publication_date,
                :format

  delegate :year, :month, to: :publication_date, allow_nil: true

  def file_size_label
    "#{format.upcase} file (#{file_size_in_kb} KB)"
  end

  def file_size_in_kb
    sprintf('%.1f', file_size.to_f / 1024)
  end
end
