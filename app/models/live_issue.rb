class LiveIssue
  include UkOnlyApiEntity

  DEFAULT_SORT = 'updated_desc'.freeze
  SUPPORTED_SORTS = %w[updated_desc updated_asc].freeze
  SUPPORTED_STATUSES = %w[active resolved].freeze

  attr_accessor :title,
                :description,
                :status,
                :commodities,
                :suggested_action,
                :date_discovered,
                :date_resolved,
                :updated_at

  class << self
    def filtered(statuses: [], sort: nil)
      selected_statuses = normalized_statuses(statuses)
      issues = filter_by_status(all, selected_statuses)

      sort_by_last_updated(issues, normalized_sort(sort))
    end

  private

    def filter_by_status(issues, statuses)
      return issues if statuses.empty? || statuses.size == SUPPORTED_STATUSES.size

      issues.select do |live_issue|
        statuses.any? { |status| live_issue.status.to_s.downcase.start_with?(status) }
      end
    end

    def normalized_sort(sort)
      SUPPORTED_SORTS.include?(sort) ? sort : DEFAULT_SORT
    end

    def normalized_statuses(statuses)
      Array(statuses).filter_map { |status|
        normalized_status = status.to_s.downcase
        normalized_status if SUPPORTED_STATUSES.include?(normalized_status)
      }.uniq
    end

    def sort_by_last_updated(issues, sort)
      issues.sort_by do |live_issue|
        sort_value = updated_at_sort_value(live_issue)
        missing_timestamp = sort_value.nil? ? 1 : 0
        comparable_timestamp = sort_value || 0

        if sort == 'updated_asc'
          [missing_timestamp, comparable_timestamp]
        else
          [missing_timestamp, -comparable_timestamp]
        end
      end
    end

    def updated_at_sort_value(live_issue)
      return if live_issue.updated_at.blank?

      live_issue.updated_at.to_time.to_i
    rescue ArgumentError, NoMethodError
      nil
    end
  end
end
