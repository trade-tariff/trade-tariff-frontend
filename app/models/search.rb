require 'api_entity'

class Search
  include ApiEntity

  attr_reader   :q        # search text query
  attr_accessor :country, # search country
                :day,
                :month,
                :year,
                :as_of    # legacy format for specifying date

  delegate :today?, to: :date

  def initialize(attributes = {})
    attributes['country'].gsub!(/[^a-zA-Z]/, '') if attributes['country']
    super
  end

  def perform
    retries = 0
    begin
      response = self.class.post('/search', q: q, as_of: date.to_s(:db))

      raise ApiEntity::Error if response.status == 500

      response = TariffJsonapiParser.new(response.body).parse
      Outcome.new(response)
    rescue StandardError
      if retries < Rails.configuration.x.http.max_retry
        retries += 1
        retry
      else
        raise
      end
    end
  end

  def q=(term)
    @q = term.to_s.gsub(/(\[|\])/, '')
  end

  def countries
    @countries ||= GeographicalArea.all.compact
  end

  def geographical_area
    countries.detect do |country|
      country.id == attributes['country']
    end
  end

  def date
    @date ||= TariffDate.build(attributes)
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
