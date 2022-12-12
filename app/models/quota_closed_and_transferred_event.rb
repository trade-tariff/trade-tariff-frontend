require 'api_entity'

class QuotaClosedAndTransferredEvent
  include ApiEntity

  attr_accessor :transferred_amount, :closing_date

  has_one :quota_definition, class_name: 'OrderNumber::Definition'

  def presented_balance_text
    "#{quota_definition.measurement_unit}, transferred from the previous quota period (#{quota_definition.validity_start_date.to_date.to_formatted_s(:long)} to #{quota_definition.validity_end_date.to_date.to_formatted_s(:long)}) on #{closing_date.to_date.to_formatted_s(:long)}."
  end

  def presented_transferred_amount
    transferred_amount
  end
end
