require 'api_entity'

class Search
  include ApiEntity

  attr_accessor :q,       # search text query
                :country, # search country
                :day,
                :month,
                :year,
                :as_of    # legacy format for specifying date

  delegate :today?, to: :date

  def initialize(attributes = {})
    attributes['currency'].gsub!(/[^a-zA-Z]/, '') if attributes['currency']
    attributes['country'].gsub!(/[^a-zA-Z]/, '') if attributes['country']
    super
  end

  def perform
    retries = 0
    begin
      response = self.class.post('/search', q: q, as_of: date.to_s(:db), currency: currency)

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
    [geographical_area].compact
  end

  def geographical_area
    GeographicalArea.cached_countries.detect do |country|
      country.id == attributes['country']
    end
  end

  def date
    @date ||= if as_of.present?
                TariffDate.new(as_of)
              else
                TariffDate.parse(attributes.slice(*TariffDate::DATE_KEYS))
              end
  end

  def currency_name
    case currency
    when 'GBP'
      'Pound sterling'
    else
      'Euro'
    end
  end

  def currency
    attributes['currency'] || TradeTariffFrontend.currency_default
  end

  def filtered_by_date?
    date.date != TariffUpdate.latest_applied_import_date
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
    { 'day'  => date.day,
      'year' => date.year,
      'month' => date.month }.merge(attributes.slice(:country, :currency))
  end

  def to_s
    q
  end

  def id
    q
  end
end
