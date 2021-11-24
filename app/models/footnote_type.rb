class FootnoteType
  include ApiEntity

  collection_path '/footnote_types'

  attr_accessor :footnote_type_id, :description
end
