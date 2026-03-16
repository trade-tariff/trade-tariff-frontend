module Myott
  class ImpactedMeasuresPresenter
    include Enumerable

    attr_reader :changes

    def initialize(changes)
      @changes = changes
    end

    def each(&block)
      @changes.each(&block)
    end

    def has_additional_code?
      @changes.any? { |change| change['additional_code'].present? }
    end

    def has_quota_order_number?
      @changes.any? { |change| change['quota_order_number'].present? }
    end
  end
end
