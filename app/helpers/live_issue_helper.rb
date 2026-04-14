module LiveIssueHelper
  def markdown_field(markdown)
    raw Kramdown::Document.new(markdown).to_html
  end

  def live_issue_status_sort_link(sort_direction)
    current_direction = sort_direction == 'desc' ? 'desc' : 'asc'
    next_direction = current_direction == 'asc' ? 'desc' : 'asc'

    link_to live_issues_path(sort: next_direction), class: 'govuk-link govuk-link--no-visited-state' do
      safe_join([
        'Status',
        tag.span(sort_arrow(current_direction), aria: { hidden: true }),
        tag.span("sorted #{sort_direction_label(current_direction)}", class: 'govuk-visually-hidden'),
      ], ' ')
    end
  end

  def live_issue_from_to_date(live_issue)
    from = live_issue.date_discovered.to_date.to_formatted_s(:long)
    to = live_issue.date_resolved ? live_issue.date_resolved&.to_date&.to_formatted_s(:long) : 'Present'

    "#{from} - #{to}"
  end

private

  def sort_arrow(direction)
    (direction == 'desc' ? '&#8595;' : '&#8593;').html_safe
  end

  def sort_direction_label(direction)
    direction == 'desc' ? 'descending' : 'ascending'
  end
end
