class LiveIssue
  include UkOnlyApiEntity

  set_collection_path 'api/v2/live_issues'

  attr_reader :id
  attr_accessor :title,
                :description,
                :status,
                :commodities,
                :suggested_action,
                :date_discovered,
                :date_resolved,
                :updated_at
end
