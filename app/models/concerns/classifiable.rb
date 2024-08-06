module Classifiable
  extend ActiveSupport::Concern

  def descriptions_with_other_handling
    return [] unless to_s.match(/^other$/i)

    all_other = true
    descriptions = []

    ancestors.reverse.each do |ancestor|
      if ancestor.is_other?
        descriptions.unshift(ancestor.to_s)
      else
        descriptions.unshift(ancestor.to_s)
        all_other = false
        break
      end
    end

    if all_other
      descriptions.unshift(heading.to_s)
    end

    descriptions
  end

  def is_other?
    to_s.match(/^other$/i)
  end

  def to_s
    formatted_description || description
  end
end
