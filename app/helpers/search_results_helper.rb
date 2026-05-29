module SearchResultsHelper
  CONFIDENCE_LEVELS = {
    'Strong' => {
      label: 'Strong result',
      css_class: 'confidence-strong',
      needle: 'M77.9733 67.3337C78.0206 70.664 76.314 73.9208 73.2246 75.7045C68.6808 78.3278 62.8707 76.771 60.2474 72.2272C57.624 67.6835 59.1808 61.8734 63.7246 59.25C67.005 57.3561 70.9457 57.6405 73.8705 59.6552L121 37.4547L77.9733 67.3337Z',
    },
    'Good' => {
      label: 'Good result',
      css_class: 'confidence-good',
      needle: 'M73.1211 59.2021C76.0289 60.8264 77.9961 63.9327 77.9961 67.5C77.9961 72.7467 73.7428 77 68.4961 77C63.2494 77 58.9961 72.7467 58.9961 67.5C58.9961 63.7123 61.213 60.4427 64.4199 58.917L68.7588 7L73.1211 59.2021Z',
    },
    'Possible' => {
      label: 'Possible result',
      css_class: 'confidence-possible',
      needle: 'M63.6185 59.3216C66.4791 57.6154 70.1528 57.465 73.2422 59.2486C77.786 61.872 79.3428 67.6821 76.7194 72.2259C74.0961 76.7696 68.286 78.3265 63.7422 75.7031C60.462 73.8092 58.7389 70.2545 59.021 66.7144L16.2295 36.9975L63.6185 59.3216Z',
    },
  }.freeze

  UNKNOWN_CONFIDENCE = {
    label: 'Unknown',
    css_class: 'confidence-unknown',
    needle: 'M73.1211 59.2021C76.0289 60.8264 77.9961 63.9327 77.9961 67.5C77.9961 72.7467 73.7428 77 68.4961 77C63.2494 77 58.9961 72.7467 58.9961 67.5C58.9961 63.7123 61.213 60.4427 64.4199 58.917L68.7588 7L73.1211 59.2021Z',
  }.freeze

  def render_confidence_meter(confidence)
    config = CONFIDENCE_LEVELS[confidence&.capitalize] || UNKNOWN_CONFIDENCE

    content_tag(:div, class: "confidence-indicator #{config[:css_class]}") do
      confidence_gauge_svg(config[:needle]) +
        content_tag(:span, config[:label], class: 'confidence-label')
    end
  end

  def confidence_gauge_svg(needle_path)
    content_tag(:svg, width: '137', height: '81', viewBox: '0 0 137 81', fill: 'none',
                      xmlns: 'http://www.w3.org/2000/svg', class: 'confidence-gauge',
                      aria: { label: 'Confidence gauge' }) do
      # Paths and colours come from Gwyn's three Meter=Low/Medium/High source SVGs.
      content_tag(:path, nil, d: 'M42.918 27.2891C29.2902 35.7656 20.1736 50.811 20 68H0C0.175796 43.409 13.3081 21.8985 32.9111 9.95703L42.918 27.2891Z', fill: '#D4351C', data: { confidence_segment: true }) +
        content_tag(:path, nil, d: 'M68.4971 0C80.604 0 91.9773 3.14094 101.847 8.65234L91.8418 25.9805C84.9161 22.1699 76.9603 20 68.4971 20C59.466 20 51.0127 22.4706 43.7725 26.7695L33.7695 9.44336C43.9522 3.44265 55.8225 0 68.4971 0Z', fill: '#FFDD00', data: { confidence_segment: true }) +
        content_tag(:path, nil, d: 'M102.717 9.14844C123.074 20.9101 136.815 42.8437 136.995 68.002H116.995C116.816 50.2458 107.095 34.775 92.7148 26.4717L102.717 9.14844Z', fill: '#00703C', data: { confidence_segment: true }) +
        content_tag(:path, nil, d: needle_path, fill: '#0B0C0C')
    end
  end

  def normalize_options_to_json(options)
    return '[]' if options.blank?

    # If already an array, just convert to JSON
    return options.to_json if options.is_a?(Array)

    # If it's a string, try to parse it to ensure we have a clean array
    parsed = options
    3.times do
      break if parsed.is_a?(Array)
      break unless parsed.is_a?(String) && parsed.start_with?('[', '"')

      parsed = JSON.parse(parsed)
    end
    parsed.is_a?(Array) ? parsed.to_json : '[]'
  rescue JSON::ParserError
    '[]'
  end

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
