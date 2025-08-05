class LiveIssuesController < ApplicationController
  before_action :disable_switch_service_banner,
                :disable_last_updated_footnote,
                :disable_search_form

  def index
    @live_issues = LiveIssue.all
  end
end
