require 'api_entity'
require 'null_object'

class OrderNumber
  class Definition
    include ApiEntity
    include HasGoodsNomenclature

    set_collection_path '/api/v2/quotas'

    DATE_FIELDS = %w[
      blocking_period_start_date
      blocking_period_end_date
      suspension_period_start_date
      suspension_period_end_date
      validity_start_date
      validity_end_date
      last_allocation_date
    ].freeze
    DATE_HMRC_STARTED_MANAGING_PENDING_BALANCES = Date.parse('2022-07-01').freeze

    attr_accessor :quota_definition_sid, :quota_order_number_id, :initial_volume, :status, :measurement_unit,
                  :measurement_unit_qualifier,
                  :monetary_unit, :balance, :description, :goods_nomenclature_item_id

    DATE_FIELDS.each do |field|
      define_method(field.to_sym) do
        instance_variable_get("@#{field}".to_sym).presence || NullObject.new
      end

      define_method("#{field}=".to_sym) do |arg|
        instance_variable_set("@#{field}".to_sym, Time.zone.parse(arg)) if arg.present?
      end
    end

    has_one :order_number
    has_many :measures

    has_one :incoming_quota_closed_and_transferred_event, class_name: 'QuotaClosedAndTransferredEvent'

    delegate :present?, to: :status
    delegate :warning_text, :show_warning?, to: :order_number, allow_nil: true

    def id
      @id ||= quota_definition_sid
    end

    def order_number
      # Returns the order number when loaded via the quota tools page
      return @order_number if @order_number
      # Returns the order number when the definition is loaded as part of a declarable response
      return casted_by if casted_by.is_a?(OrderNumber)
    end

    def geographical_areas
      order_number&.geographical_areas.presence || measures&.map(&:geographical_area) || []
    end

    def suspension_period?
      suspension_period_start_date.present? && suspension_period_end_date.present?
    end

    def blocking_period?
      blocking_period_start_date.present? && blocking_period_end_date.present?
    end

    def first_goods_nomenclature_short_code
      all_goods_nomenclatures.select { |gn| gn.respond_to?(:short_code) }
                             .first
                             &.short_code
    end

    def shows_balance_transfers?
      validity_start_date.to_date >= DATE_HMRC_STARTED_MANAGING_PENDING_BALANCES
    end
  end
end
