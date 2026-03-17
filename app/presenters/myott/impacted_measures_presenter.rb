module Myott
  class ImpactedMeasuresPresenter
    include Enumerable

    def initialize(changes, trade_direction:)
      @changes = changes
      @trade_direction = trade_direction
    end

    def each(&block)
      decorated_changes.each(&block)
    end

    def has_additional_code?
      @changes.any? { |change| change['additional_code'].present? }
    end

    def has_quota_order_number?
      @changes.any? { |change| change['quota_order_number'].present? }
    end

    private

    def decorated_changes
      @decorated_changes ||= @changes.map do |change|
        ImpactedMeasureChangePresenter.new(change, trade_direction: @trade_direction)
      end
    end
  end
end
