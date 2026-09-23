module HasExcludedCountries
  extend ActiveSupport::Concern

  def excluded_country_list(as_of:)
    return ''.html_safe if excluded_countries.blank?

    countries = excluded_countries.dup

    if exclusions_include_european_union?(as_of:)
      countries.delete_if { |country| country.eu_member?(as_of:) }
      countries.unshift(GeographicalArea.european_union(as_of:))
    end

    countries.map(&:description).sort.join(', ').html_safe
  rescue Faraday::Error => e
    Rails.logger.warn "Unable to resolve replace EU exclusion list, as_of=#{as_of}. Error: #{e.message}"
    excluded_countries.map(&:description).sort.join(', ').html_safe
  end

  def exclusions_include_european_union?(as_of:)
    return false if excluded_countries.blank?

    GeographicalArea.eu_members_ids(as_of:).all? { |eu_member| eu_member.in?(excluded_country_ids) }
  rescue Faraday::Error => e
    Rails.logger.warn "Failed to fetch EU member countries list, as_of=#{as_of}. Error: #{e.message}"
    false
  end

  private

  def excluded_country_ids
    @excluded_country_ids ||= excluded_countries.map(&:id)
  end
end
