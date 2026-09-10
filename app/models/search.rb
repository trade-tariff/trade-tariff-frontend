class Search
  include ApiEntity
  include CacheHelper

  class InvalidDate < StandardError; end

  COMMODITY_CODE = /\A[0-9]{10}\z/
  HEADING_CODE = /\A[0-9]{4}\z/
  INTERNAL_RESULT_CACHE_TTL = 30.minutes
  GUIDED_REQUEST_ID_PATTERN = /\A[a-zA-Z0-9-]{1,64}\z/

  attr_reader   :q,      # search text query
                :country # search country
  attr_accessor :day,
                :month,
                :year,
                :resource_id,
                :interactive_search,
                :answers,
                :request_id,
                :expanded_query,
                :experiment

  delegate :today?, to: :date

  def initialize(attributes = {})
    attributes['country'].gsub!(/[^a-zA-Z]/, '') if attributes['country']
    super
  end

  def country=(country)
    @country = country&.upcase
  end

  def perform
    if interactive_search && interactive_search_enabled?
      perform_internal_search
    else
      perform_v2_search
    end
  end

  def q=(term)
    @q = term.to_s.gsub(/(\[|\])/, '').strip
  end

  def countries
    @countries ||= Rails.cache.resilient_fetch([cache_key, 'GeographicalArea.all']) { GeographicalArea.all.compact }
  end

  def geographical_area
    @geographical_area ||= Rails.cache.resilient_fetch([cache_key, country]) { GeographicalArea.find(country) } if country.present?
  end

  def date
    @date ||= TariffDate.build(attributes)
  rescue Date::Error
    raise Search::InvalidDate
  end

  def as_of
    {
      1 => year.presence || Time.zone.today.year,
      2 => month.presence || Time.zone.today.month,
      3 => day.presence || Time.zone.today.day,
    }
  end

  def filtered_by_date?
    date != Time.zone.today
  end

  def day_month_and_year_set?
    day.present? && month.present? && year.present?
  end

  def filtered_by_country?
    country.present?
  end

  def any_filter_active?
    filtered_by_date? || filtered_by_country?
  end

  def contains_search_term?
    q.present?
  end

  def missing_search_term?
    !contains_search_term?
  end

  def search_term_is_commodity_code?
    COMMODITY_CODE.match? q
  end

  def search_term_is_heading_code?
    HEADING_CODE.match? q
  end

  def search_term_is_heading_level_commodity_code?
    search_term_is_commodity_code? && GoodsNomenclature.is_heading_id?(q)
  end

  def query_attributes
    {
      'day' => date.day,
      'year' => date.year,
      'month' => date.month,
    }.merge(attributes.slice(:country))
  end

  def to_s
    q
  end

  def id
    q
  end

  def internal_search_params
    { q:,
      as_of: date.to_fs(:db),
      answers: answers.presence,
      request_id: request_id.presence,
      expanded_query: expanded_query.presence,
      experiment: experiment.presence }.compact
  end

  def self.internal_result(body)
    body = JSON.parse(body) unless body.is_a?(Hash)
    parsed_data = TariffJsonapiParser.new(body).parse
    parsed_data = [] unless parsed_data.is_a?(Array)
    InternalSearchResult.new(parsed_data, body['meta'])
  end

  def self.cached_queued_result(id)
    result = Rails.cache.resilient_read(queued_result_cache_key(id))
    result if result.is_a?(InternalSearchResult)
  end

  def self.cache_queued_result(id, result)
    Rails.cache.resilient_write(queued_result_cache_key(id), result, expires_in: INTERNAL_RESULT_CACHE_TTL)
  end

  def self.queued_result_cache_key(id)
    "queued_search/#{TradeTariffFrontend::ServiceChooser.service_name}/#{id}"
  end
  private_class_method :queued_result_cache_key

  def interactive_search_cache_key
    digest = Digest::SHA256.hexdigest(MultiJson.dump({ q:, answers:, as_of: date.to_fs(:db), expanded_query:, experiment:, request_id: }))
    "interactive_search/#{digest}"
  end

  private

  def interactive_search_enabled?
    TradeTariffFrontend.interactive_search_enabled?
  end

  def perform_v2_search
    params = { q:, as_of: date.to_fs(:db), resource_id: }
    params[:request_id] = request_id if request_id.present?
    params[:experiment] = experiment if experiment.present?

    response = self.class.post('search', params)
    response = TariffJsonapiParser.new(response.body).parse

    Outcome.new(response)
  end

  def perform_internal_search
    Rails.cache.resilient_fetch(interactive_search_cache_key, expires_in: INTERNAL_RESULT_CACHE_TTL) do
      api_host = TradeTariffFrontend::ServiceChooser.api_host
      path = "#{URI.parse(api_host).path.sub(%r{/api\b}, '/internal')}/search"

      response = self.class.api.post(path, MultiJson.dump(internal_search_params), 'Content-Type' => 'application/json') do |request|
        request.options.timeout = TradeTariffFrontend::ServiceTimeout.timeout_for('/internal/search')
      end
      self.class.internal_result(response.body)
    end
  rescue Faraday::UnprocessableContentError => e
    hydrate_errors_from_response(e)
    InternalSearchResult.new([], nil)
  end
end
