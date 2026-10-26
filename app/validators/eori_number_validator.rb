# Users sometimes enter a GB or XI EORI number in the tariff search. The search
# cannot check EORI numbers, so reject them before a backend search runs.
class EoriNumberValidator < ActiveModel::EachValidator
  PATTERN = /\A(?:GB|XI)\d{9,}\z/i
  MESSAGE = 'The Online Trade Tariff does not recognise EORI numbers. Search using a commodity code or a description of your goods'.freeze

  def self.eori_number?(value)
    PATTERN.match?(value.to_s.gsub(/\s/, ''))
  end

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :eori_number, message: MESSAGE) if self.class.eori_number?(value)
  end
end
