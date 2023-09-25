require 'api_entity'

class Chemical
  include ApiEntity

  attr_accessor :cas, :name, :goods_nomenclatures, :id
end
