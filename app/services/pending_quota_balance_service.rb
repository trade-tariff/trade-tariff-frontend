class PendingQuotaBalanceService
  QUOTA_FIRST_QUARTER_DAY = 1
  QUOTA_FIRST_QUARTER_MONTH = 7

  attr_reader :declarable_id,
              :quota_order_number_id,
              :chosen_period,
              :data_model

  def initialize(declarable_id, quota_order_number_id, chosen_period)
    @declarable_id = declarable_id
    @quota_order_number_id = quota_order_number_id
    @chosen_period = chosen_period
    @data_model = declarable_id.length == 4 ? Heading : Commodity
  end

  def call
    pending_balance
  end

private

  def declarable
    @declarable ||= data_model.find(declarable_id, as_of: chosen_period)
  end

  def quota_measure
    declarable.import_measures.find_by_quota_order_number(quota_order_number_id)
  end

  def definition
    @definition ||= quota_measure&.order_number&.definition
  end

  def previous_period_declarable
    @previous_period_declarable ||= data_model.find(declarable_id, as_of: previous_period)
  end

  def previous_quota_measure
    previous_period_declarable.import_measures.find_by_quota_order_number(quota_order_number_id)
  end

  def previous_period_definition
    previous_quota_measure&.order_number&.definition
  end

  def pending_balance
    if show_pending_balances?
      begin
        previous_period_definition&.balance
      rescue Faraday::ResourceNotFound
        nil
      end
    end
  end

  def previous_period
    (definition.validity_start_date - 1.day).to_date
  end

  def show_pending_balances?
    declarable.import_measures.any? &&
      declarable.has_safeguard_measure? &&
      not_current_definition_first_quarter? &&
      definition.shows_balance_transfers?
  end

  def not_current_definition_first_quarter?
    !current_definition_first_quarter?
  end

  def current_definition_first_quarter?
    current_definition_start_day == QUOTA_FIRST_QUARTER_DAY &&
      current_definition_start_month == QUOTA_FIRST_QUARTER_MONTH
  end

  def current_definition_start_day
    definition.validity_start_date.to_date.day
  end

  def current_definition_start_month
    definition.validity_start_date.to_date.month
  end
end
