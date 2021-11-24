class Footnote
  include ApiEntity

  ECO_CODE = '05002'.freeze

  collection_path '/footnotes'

  attr_accessor :code, :footnote_type_id, :footnote_id, :description, :formatted_description, :extra_large_measures

  has_many :measures
  has_many :goods_nomenclatures

  def id
    @id ||= "#{casted_by.destination}-#{casted_by.id}-footnote-#{code}"
  end

  def eco?
    code == ECO_CODE
  end
end
