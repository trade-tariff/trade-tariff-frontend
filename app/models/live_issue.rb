class LiveIssue
  include UkOnlyApiEntity

  attr_accessor :title,
                :description,
                :status,
                :commodities,
                :suggested_action,
                :date_discovered,
                :date_resolved,
                :updated_at

  class << self
    def sorted_by_status(sort_direction = 'asc')
      all.sort_by do |live_issue|
        [status_sort_rank(live_issue, sort_direction), -updated_at_sort_value(live_issue)]
      end
    end

  private

    def status_sort_rank(live_issue, sort_direction)
      active_status = live_issue.status.to_s.casecmp('active').zero?

      if sort_direction == 'desc'
        active_status ? 1 : 0
      else
        active_status ? 0 : 1
      end
    end

    def updated_at_sort_value(live_issue)
      return 0 if live_issue.updated_at.blank?

      live_issue.updated_at.to_time.to_i
    rescue ArgumentError, NoMethodError
      0
    end
  end
end
