require 'api_entity'

class Search
  include ApiEntity
  include CacheHelper

  class InvalidDate < StandardError; end

  COMMODITY_CODE = /\A[0-9]{10}\z/
  HEADING_CODE = /\A[0-9]{4}\z/

  attr_reader   :q,      # search text query
                :country # search country
  attr_accessor :day,
                :month,
                :year,
                :resource_id

  delegate :today?, to: :date

  def initialize(attributes = {})
    attributes['country'].gsub!(/[^a-zA-Z]/, '') if attributes['country']
    super
  end

  def country=(country)
    @country = country&.upcase
  end

  def perform
    response = self.class.post(
      '/api/v2/search',
      q:,
      as_of: date.to_fs(:db),
      resource_id:,
    )
    response = TariffJsonapiParser.new(response.body).parse

    Outcome.new(response)
  end

  def q=(term)
    @q = term.to_s.gsub(/(\[|\])/, '').strip
  end

  def countries
    @countries ||= Rails.cache.fetch([cache_key, 'GeographicalArea.all']) { GeographicalArea.all.compact }
  end

  def geographical_area
    @geographical_area ||= Rails.cache.fetch([cache_key, country]) { GeographicalArea.find(country) } if country.present?
  end

  def country_description
    geographical_area&.description || 'All countries'
  end

  def date
    @date ||= TariffDate.build(attributes)
  rescue Date::Error
    raise Search::InvalidDate
  end

  def filtered_by_date?
    date != TariffUpdate.latest_applied_import_date
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
end
