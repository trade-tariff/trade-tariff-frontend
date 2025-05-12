require 'api_entity'

class Section
  include ApiEntity

  attr_accessor :numeral,
                :position,
                :title,
                :chapters,
                :section_note,
                :description_plain

  attr_reader :chapter_to,
              :chapter_from

  has_many :chapters

  def chapter_from=(chapter_from)
    @chapter_from = chapter_from.to_i
  end

  def chapter_to=(chapter_to)
    @chapter_to = chapter_to.to_i
  end

  def chapters_title
    if chapter_from == chapter_to
      chapter_from.to_s
    else
      "#{chapter_from} to #{chapter_to}"
    end
  end

  def to_param
    position.to_s
  end

  delegate :count, to: :chapters, prefix: true

  def to_s
    title
  end

  def page_heading
    "Section #{numeral} - #{title}"
  end
end
