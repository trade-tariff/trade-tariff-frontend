class GeographicalArea
  EUROPEAN_UNION_ID = '1013'.freeze
  REFERENCING_EUROPEAN_UNION_ID = 'EU'.freeze
  ERGA_OMNES = '1011'.freeze

  include ApiEntity
  extend CacheHelper

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
    def european_union(as_of: nil)
      Rails.cache.resilient_fetch(['european_union', cache_key, EUROPEAN_UNION_ID, as_of]) do
        find(EUROPEAN_UNION_ID, as_of:)
      end
    end

    def european_union_members(as_of: nil)
      european_union(as_of:).children_geographical_areas
    end

    def eu_members_ids(as_of: nil)
      candidate_ids = european_union_members(as_of:).map(&:id)
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

  def eu_member?(as_of: nil)
    id.in?(self.class.eu_members_ids(as_of:)) || id == REFERENCING_EUROPEAN_UNION_ID
  end

  def long_description
    "#{description} (#{id})"
  end

  def to_s
    description
  end
end
