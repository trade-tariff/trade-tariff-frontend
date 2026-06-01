module LiveIssueHelper
  SORT_LABELS = {
    'updated_desc' => 'live_issues.sort.updated_desc',
    'updated_asc' => 'live_issues.sort.updated_asc',
  }.freeze

  STATUS_FILTER_LABELS = {
    'active' => 'live_issues.status_filters.active',
    'resolved' => 'live_issues.status_filters.resolved',
  }.freeze

  STATUS_LABELS = {
    'active' => 'live_issues.status_labels.active',
    'resolved' => 'live_issues.status_labels.resolved',
  }.freeze

  def markdown_field(markdown)
    govuk_linkified_html(govspeak(markdown))
  end

  def live_issue_recommendation(live_issue)
    return t('live_issues.card.none') if live_issue.suggested_action.blank?

    markdown_field(live_issue.suggested_action)
  end

  def live_issue_from_to_date(live_issue)
    from = live_issue.date_discovered.to_date.to_formatted_s(:long)
    to = live_issue.date_resolved ? live_issue.date_resolved&.to_date&.to_formatted_s(:long) : 'Present'

    "#{from} - #{to}"
  end

  def live_issue_updated_at(live_issue)
    return t('live_issues.card.not_available') if live_issue.updated_at.blank?

    live_issue.updated_at.to_date.to_formatted_s(:long)
  rescue ArgumentError, NoMethodError
    t('live_issues.card.not_available')
  end

  def live_issue_sort_label(sort)
    t(SORT_LABELS.fetch(sort, SORT_LABELS.fetch(LiveIssue::DEFAULT_SORT)))
  end

  def live_issue_status_filter_label(status)
    normalized_status = status.to_s.downcase
    label_key = STATUS_FILTER_LABELS[normalized_status]

    label_key ? t(label_key) : status.to_s
  end

  def live_issue_status_filter_selected?(status_filters, status)
    Array(status_filters).include?(status)
  end

  def live_issue_active_filter_labels(status_filters:, sort:)
    labels = []
    if sort.present? && sort != LiveIssue::DEFAULT_SORT
      labels << t('live_issues.filters.sort_chip', label: live_issue_sort_label(sort)).delete_prefix('× ')
    end

    Array(status_filters).each do |status|
      labels << t('live_issues.filters.status_chip', label: live_issue_status_label(status)).delete_prefix('× ')
    end

    labels
  end

  def live_issue_status_label(status)
    normalized_status = status.to_s.downcase
    return t(STATUS_LABELS.fetch('active')) if normalized_status.start_with?('active')
    return t(STATUS_LABELS.fetch('resolved')) if normalized_status.start_with?('resolved')

    status
  end

  def live_issue_status_tag_class(status)
    normalized_status = status.to_s.downcase
    return 'govuk-tag--yellow' if normalized_status.start_with?('active')
    return 'govuk-tag--green' if normalized_status.start_with?('resolved')

    ''
  end

  def live_issue_filter_path_without_sort
    live_issues_path(status: @status_filters.presence)
  end

  def live_issue_filter_path_without_status(status)
    remaining_statuses = Array(@status_filters) - [status]

    live_issues_path(sort: @applied_sort, status: remaining_statuses.presence)
  end

private

  def govuk_linkified_html(html)
    fragment = Nokogiri::HTML::DocumentFragment.parse(html.to_s)

    fragment.css('a').each do |link|
      link['class'] = (link['class'].to_s.split | %w[govuk-link govuk-link--no-visited-state]).join(' ')
    end

    fragment.to_html.html_safe
  end
end
