require 'api_entity'

class GeographicalArea
  EUROPEAN_UNION_ID = '1013'.freeze

  include ApiEntity

  collection_path '/geographical_areas/countries'

  attr_accessor :id, :geographical_area_id

  attr_writer :description

  has_many :children_geographical_areas, class_name: 'GeographicalArea'

  ERGA_OMNES = '1011'.freeze # Entire world

  class << self
    def european_union
      @european_union ||= find(EUROPEAN_UNION_ID)
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
      all.compact.map do |geographical_area|
        [
          geographical_area.long_description,
          geographical_area.id,
        ]
      end
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
    id.in?(self.class.eu_members_ids)
  end

  def long_description
    "#{description} (#{id})"
  end

  def to_s
    description
  end

  def erga_omnes?
    id == ERGA_OMNES
  end
end
