require 'api_entity'

class RulesOfOrigin::Article
  include ApiEntity

  attr_accessor :article, :content

  def text
    content.sub(/{{.*}}/i, '') if content
  end

  def ord_reference
    content.scan(/{{(.*)}}/i).first&.first&.strip if content
  end

  def ord_reference?
    !ord_reference.nil?
  end

  def sections
    return [] unless content

    @sections ||= content.split(/^(## )/m)
                         .map(&:presence)
                         .compact
                         .slice_before('## ')
                         .select { |marker, _| marker == '## ' }
                         .map(&:join)
  end

  def section(section_number)
    section_number = section_number.to_i - 1
    sections[section_number.positive? ? section_number : 0]
  end

  def subheadings
    sections.map do |content|
      content.lines(chomp: true)
             .first
             .sub(/^## /, '')
    end
  end
end
