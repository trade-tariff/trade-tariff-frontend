class Chemical
  include ApiEntity

  collection_path '/chemicals'

  attr_accessor :cas, :name, :goods_nomenclatures, :id
end
