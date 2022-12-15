require 'api_entity'

class QuotaClosedAndTransferredEvent
  include ApiEntity

  attr_accessor :transferred_amount,
                :closing_date,
                :quota_definition_validity_start_date,
                :quota_definition_validity_end_date,
                :quota_definition_measurement_unit,
                :target_quota_definition_validity_start_date,
                :target_quota_definition_validity_end_date,
                :target_quota_definition_measurement_unit

  def presented_balance_text
    "#{quota_definition_measurement_unit}, transferred from the previous quota period (#{presented_quota_definition_validity_start_date} to #{presented_quota_definition_validity_end_date}) on #{presented_closing_date}."
  end

  private

  def presented_closing_date
    closing_date.to_date.to_formatted_s(:long)
  end

  def presented_quota_definition_validity_start_date
    quota_definition_validity_start_date&.to_date&.to_formatted_s(:long)
  end

  def presented_quota_definition_validity_end_date
    quota_definition_validity_end_date&.to_date&.to_formatted_s(:long)
  end

  def presented_target_quota_definition_validity_start_date
    target_quota_definition_validity_start_date&.to_date&.to_formatted_s(:long)
  end

  def presented_target_quota_definition_validity_end_date
    target_quota_definition_validity_end_date&.to_date&.to_formatted_s(:long)
  end
end
