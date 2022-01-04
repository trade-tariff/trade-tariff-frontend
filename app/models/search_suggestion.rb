require 'api_entity'

class SearchSuggestion
  include ApiEntity
  CACHE_VERSION = 'v1'.freeze

  collection_path '/search_suggestions'

  attr_accessor :value

  class << self
    def cached_suggestions_for(term)
      return [] if term.blank?

      first_letter = term.slice(0, 1).downcase
      cached_suggestions_for_letter first_letter
    end

    def start_with(term)
      cached_suggestions_for(term).select { |s| s.value =~ /^#{term}/i }
                                  .first(TradeTariffFrontend.suggestions_count)
    end

  private

    def cached_suggestions_for_letter(first_letter)
      results = Rails.cache.read_multi "#{cache_prefix}loaded",
                                       "#{cache_prefix}#{first_letter}"

      if results["#{cache_prefix}loaded"]
        return results["#{cache_prefix}#{first_letter}"] || []
      end

      grouped_results = all.group_by { |r| r.value.to_s.downcase.slice(0, 1) }

      grouped_results.transform_keys! { |letter| "#{cache_prefix}#{letter}" }
      grouped_results["#{cache_prefix}loaded"] = true

      Rails.cache.write_multi grouped_results, expires_in: 24.hours

      grouped_results["#{cache_prefix}#{first_letter}"].presence || []
    end

    def cache_prefix
      "#{TradeTariffFrontend::ServiceChooser.cache_prefix}.#{CACHE_VERSION}.search_suggestions_"
    end
  end
end
