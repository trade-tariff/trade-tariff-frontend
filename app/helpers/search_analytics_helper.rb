module SearchAnalyticsHelper
  def search_analytics_context
    evaluation = @search_feature_evaluation || { enabled: false, source: 'default', reason: 'missing_evaluation' }
    enabled = evaluation[:enabled]

    {
      event: 'ott_search_context',
      search_experience: enabled ? 'guided_beta' : 'classic',
      search_mode: search_analytics_mode(enabled),
      search_state: search_analytics_state,
      feature_flag_name: 'interactive_search',
      feature_flag_enabled: enabled,
      feature_flag_source: evaluation[:source],
      feature_flag_fallback_reason: evaluation[:reason],
      request_id: search_analytics_request_id,
      experiment: Current.experiment,
      question_count: nil,
      option_count: nil,
      result_count: search_analytics_results? ? @results&.size : nil,
      client_elapsed_ms: nil,
      client_navigation_ms: nil,
      used_dont_know: false,
      result_rank: nil,
      confidence: nil,
      goods_nomenclature_item_id: nil,
      outcome: nil,
      destination: nil,
    }.merge(@guided_search_metrics || {})
  end

  private

  def search_analytics_mode(enabled)
    return 'guided' if @guided_search_outcome.present?
    return 'guided' if enabled && controller_name == 'find_commodities' && cookies[:interactive_search] == 'true'

    'keyword'
  end

  def search_analytics_state
    return @guided_search_outcome if @guided_search_outcome.present?
    return 'entry' if controller_name == 'find_commodities'
    return unless search_analytics_results?

    @results&.any? ? 'results' : 'no_results'
  end

  def search_analytics_results?
    controller_name == 'search' && action_name == 'search'
  end

  def search_analytics_request_id
    identifier = @search&.request_id.to_s
    identifier if identifier.match?(/\A[a-zA-Z0-9-]{1,64}\z/)
  end
end
