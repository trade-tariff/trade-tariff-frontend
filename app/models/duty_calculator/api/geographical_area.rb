module DutyCalculator
  module Api
    class GeographicalArea < Api::Base
      EU = '1013'.freeze
      UK = %w[GB].freeze

      has_many :children_geographical_areas, GeographicalArea

      attributes :id,
                 :geographical_area_id,
                 :description

      def id
        geographical_area_id
      end

      def name
        description.html_safe
      end

      def long_description
        "#{description} (#{geographical_area_id})"
      end

      def european_union?
        geographical_area_id == EU
      end

      def self.list_countries(service)
        countries = build_collection(service, 'Country')
        countries << northern_ireland if service == :uk
        countries
      end

      def self.non_eu_countries
        eu_ids = european_union_members.map(&:geographical_area_id).concat(UK)
        build_collection(:xi, 'Country')
          .reject { |country| eu_ids.include?(country.geographical_area_id) }
      end

      def self.european_union_members
        as_of = default_query.fetch('as_of')

        # EU membership changes rarely, but it is date specific, so the key
        # includes the import date used by the request.
        rows = Rails.cache.resilient_fetch(['duty_calculator', 'eu_members', 'xi', as_of], expires_in: 24.hours) do
          build(:xi, EU).children_geographical_areas.map(&:attributes)
        end

        rows.map { |attributes| new(attributes) }
      end

      def self.eu_member?(geographical_area_id)
        european_union_members.map(&:geographical_area_id).include?(geographical_area_id)
      end

      def self.northern_ireland
        new(id: 'XI', description: 'United Kingdom (Northern Ireland)', geographical_area_id: 'XI')
      end
    end
  end
end
