require 'api_entity'

class SearchReference
  include ApiEntity

  attr_accessor :id, :title, :referenced_id, :referenced_class, :productline_suffix

  def referenced_entity
    reference_class.new(attributes['referenced'])
  end

  private

  def reference_class
    attributes['referenced_class'].constantize
  end
end
