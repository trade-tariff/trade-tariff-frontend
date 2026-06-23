class SearchReference
  include ApiEntity

  attr_accessor :id, :title, :referenced_id, :referenced_class, :productline_suffix
end
