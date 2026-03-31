class LiveIssuesController < ApplicationController
  before_action :disable_switch_service_banner,
                :disable_last_updated_footnote,
                :disable_search_form

  def index
    @sort_direction = sort_direction
    @live_issues = sorted_live_issues
  end

private

  def sorted_live_issues
    LiveIssue.all.sort_by do |live_issue|
      [status_sort_rank(live_issue), -updated_at_sort_value(live_issue)]
    end
  end

  def status_sort_rank(live_issue)
    active_status = live_issue.status.to_s.casecmp('active').zero?

    if @sort_direction == 'desc'
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

  def sort_direction
    params[:sort] == 'desc' ? 'desc' : 'asc'
  end
end
