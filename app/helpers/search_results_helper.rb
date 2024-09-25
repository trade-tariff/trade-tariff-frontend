module SearchResultsHelper
  def descriptions_with_other_handling(commodity)
    return sanitize commodity.description.to_s unless commodity.description.to_s.match(/^other/i)

    ancestor_descriptions = commodity.ancestor_descriptions.reverse

    descriptions = []

    ancestor_descriptions.each do |ancestor_description|
      descriptions.unshift(ancestor_description.to_s)

      break unless ancestor_description.to_s.match(/^other/i)
    end

    descriptions[-1] = tag.strong(descriptions.last)
    descriptions = descriptions.join(' > ')

    sanitize descriptions
  end
end
