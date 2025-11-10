module HasExcludedCountries
  extend ActiveSupport::Concern

  def excluded_country_list
    countries = if exclusions_include_european_union?
                  # Replace EU members with the EU geographical_area
                  [GeographicalArea.european_union] + excluded_countries.delete_if(&:eu_member?)
                else
                  excluded_countries
                end

    countries.map(&:description).join(', ').html_safe
  end

  def exclusions_include_european_union?
    GeographicalArea.eu_members_ids.all? { |eu_member| eu_member.in?(excluded_country_ids) }
  end

  private

  def excluded_country_ids
    @excluded_country_ids ||= excluded_countries.map(&:id)
  end
end
