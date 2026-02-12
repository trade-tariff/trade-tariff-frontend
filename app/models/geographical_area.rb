require 'api_entity'

class GeographicalArea
  EUROPEAN_UNION_ID = '1013'.freeze
  REFERENCING_EUROPEAN_UNION_ID = 'EU'.freeze
  ERGA_OMNES = '1011'.freeze

  include ApiEntity

  enum :id, {
    channel_islands: '1080',
    erga_omnes: '1011',
    european_union: '1013',
  }

  set_collection_path 'geographical_areas/countries'

  attr_accessor :id, :geographical_area_id

  attr_writer :description

  has_many :children_geographical_areas, class_name: 'GeographicalArea'

  class << self
    def european_union
      @european_union ||= Rails.cache.fetch("european_union", EUROPEAN_UNION_ID) do
        find(EUROPEAN_UNION_ID).tap do |eu|
          if eu.description != 'European Union'
            info = {
              id: eu.id,
              description: eu.description,
              messages: "EU description is '#{eu.description}' instead of 'European Union'",
              cache: from_cache
            }
            Rails.logger.warn info.to_json
          end
        end
      end
    end

    def european_union_members
      european_union.children_geographical_areas
    end

    def eu_members_ids
      candidate_ids = european_union_members.map(&:id)
      candidate_ids.delete('EU')
      candidate_ids
    end

    def country_options
      options = all.compact
                   .sort_by(&:long_description)
                   .map do |geographical_area|
                     [
                       geographical_area.long_description,
                       geographical_area.id,
                     ]
                   end

      options.unshift(['All countries', ' '])

      options
    end
  end

  def description
    if erga_omnes?
      'All countries'
    else
      attributes['description'].presence || ''
    end
  end

  def eu_member?
    id.in?(self.class.eu_members_ids) || id == REFERENCING_EUROPEAN_UNION_ID
  end

  def long_description
    "#{description} (#{id})"
  end

  def to_s
    description
  end
end
