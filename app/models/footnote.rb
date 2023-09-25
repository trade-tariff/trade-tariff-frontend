require 'api_entity'

class Footnote
  include ApiEntity

  CRITICAL_WARNING_REGEX = /^CR/

  attr_accessor :code,
                :footnote_type_id,
                :footnote_id,
                :description,
                :formatted_description

  has_many :goods_nomenclatures, polymorphic: true

  def critical_warning?
    code =~ CRITICAL_WARNING_REGEX
  end
end
