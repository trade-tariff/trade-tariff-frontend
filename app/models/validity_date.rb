require 'api_entity'

class ValidityDate
  include ApiEntity

  attr_accessor :goods_nomenclature_item_id
  attr_reader   :validity_start_date, :validity_end_date

  class << self
    def all(parent_class, parent_id, *args)
      collection collection_path(parent_class, parent_id), *args
    end

  private

    def collection_path(parent_class, parent_id)
      "#{parent_class.collection_path}/#{parent_id}/validity_dates"
    end
  end

  def validity_start_date=(date)
    @validity_start_date = parse_date(date)
  end

  def validity_end_date=(date)
    @validity_end_date = parse_date(date)
  end

private

  def parse_date(date)
    case date
    when String
      Date.parse(date)
    when DateTime, Time
      date.to_date
    else
      date
    end
  end
end
