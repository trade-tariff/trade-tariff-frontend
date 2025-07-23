module LiveIssueHelper
  def markdown_field(markdown)
    raw Kramdown::Document.new(markdown).to_html
  end

  def live_issue_from_to_date(live_issue)
    from = live_issue.date_discovered.to_date.to_formatted_s(:long)
    to = live_issue.date_resolved ? live_issue.date_resolved&.to_date&.to_formatted_s(:long) : 'Present'

    "#{from} - #{to}"
  end
end
