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
end
