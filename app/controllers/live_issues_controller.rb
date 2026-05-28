class LiveIssuesController < ApplicationController
  LIVE_ISSUES_PER_PAGE = 4

  before_action :disable_switch_service_banner,
                :disable_search_form

  def index
    @sort = sort
    @applied_sort = applied_sort
    @status_filters = status_filters
    filtered_live_issues = LiveIssue.filtered(statuses: @status_filters, sort: @sort)
    @live_issues_count = filtered_live_issues.size
    @live_issues = Kaminari.paginate_array(filtered_live_issues, total_count: @live_issues_count)
                            .page(params[:page])
                            .per(LIVE_ISSUES_PER_PAGE)
  end

private

  def applied_sort
    LiveIssue::SUPPORTED_SORTS.include?(params[:sort]) ? params[:sort] : nil
  end

  def sort
    LiveIssue::SUPPORTED_SORTS.include?(params[:sort]) ? params[:sort] : LiveIssue::DEFAULT_SORT
  end

  def status_filters
    Array(params[:status]).filter_map { |status|
      normalized_status = status.to_s.downcase
      normalized_status if LiveIssue::SUPPORTED_STATUSES.include?(normalized_status)
    }.uniq
  end
end
