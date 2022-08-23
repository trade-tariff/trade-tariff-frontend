module SearchResult
  class SectionSerializer < SimpleDelegator
    include ActiveModel::Serializers::JSON
    def serializable_hash(_opts = {})
      {
        type: 'section',
        numeral:,
        position:,
        title:,
        section_note:,
        chapter_from:,
        chapter_to:
      }
    end
  end
end
