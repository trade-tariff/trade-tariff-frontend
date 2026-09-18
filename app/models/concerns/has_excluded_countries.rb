module HasExcludedCountries
  extend ActiveSupport::Concern

  def excluded_country_list(as_of:)
    countries = if exclusions_include_european_union?(as_of:)
                  # Replace EU members with the EU geographical_area
                  [GeographicalArea.european_union(as_of:)] + excluded_countries.delete_if { |country| country.eu_member?(as_of:) }
                else
                  excluded_countries
                end

    countries.map(&:description).sort.join(', ').html_safe
  end

  def exclusions_include_european_union?(as_of:)
    GeographicalArea.eu_members_ids(as_of:).all? { |eu_member| eu_member.in?(excluded_country_ids) }
  end

  private

  def excluded_country_ids
    @excluded_country_ids ||= excluded_countries.map(&:id)
  end
end
