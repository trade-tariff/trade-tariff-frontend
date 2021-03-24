require 'api_entity'

class GeographicalArea
  include ApiEntity

  collection_path '/geographical_areas/countries'

  attr_accessor :id, :geographical_area_id

  has_many :children_geographical_areas, class_name: 'GeographicalArea'

  def self.by_long_description(term)
    lookup_regexp = /#{term}/i
    all.select { |geographical_area|
      geographical_area.long_description =~ lookup_regexp
    }.sort_by do |geographical_area|
      match_id = geographical_area.id =~ lookup_regexp
      match_desc = geographical_area.description =~ lookup_regexp
      key = ''
      key << (match_id ? '0' : '1')
      key << (match_desc || '')
      key << geographical_area.id
      key
    end
  end

  def description
    if geographical_area_id == '1011'
      'All countries'
    else
      attributes['description'].presence || ''
    end
  end

  def long_description
    "#{description} (#{id})"
  end

  def to_s
    description
  end
end
