require 'api_entity'

class GreenLanes::GoodsNomenclature
  include XiOnlyApiEntity

  attr_accessor :goods_nomenclature_item_id,
                :description,
                :formatted_description,
                :validity_start_date,
                :validity_end_date,
                :description_plain,
                :producline_suffix

  has_many :applicable_category_assessments, class_name: 'GreenLanes::CategoryAssessment'

  def all(opts = {})
    raise NotImplementedError, 'This method is not implemented'
  end

  def filter_by_category(category)
    if applicable_category_assessments.any?
      grouped = applicable_category_assessments.group_by(&:category)
      grouped[category]
    end
  end
end
