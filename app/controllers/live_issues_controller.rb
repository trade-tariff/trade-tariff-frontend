class LiveIssuesController < ApplicationController
  before_action :disable_switch_service_banner,
                :disable_last_updated_footnote,
                :disable_search_form

  def index
    @sort_direction = sort_direction
    @live_issues = LiveIssue.sorted_by_status(@sort_direction)
  end

private

  def sort_direction
    params[:sort] == 'desc' ? 'desc' : 'asc'
  end
end
