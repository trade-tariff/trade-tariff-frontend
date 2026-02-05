module SearchResultsHelper
  CONFIDENCE_LEVELS = {
    'Strong' => { label: 'Strong match', css_class: 'confidence-strong', needle: 'M124.48 44.35L77.91 68.35L74.58 60.31L124.48 44.35Z' },
    'Good' => { label: 'Good match', css_class: 'confidence-good', needle: 'M91.72 11.59L75.75 61.49L67.72 58.16L91.72 11.59Z' },
    'Possible' => { label: 'Possible match', css_class: 'confidence-possible', needle: 'M45.38 11.59L69.38 58.16L61.34 61.49L45.38 11.59Z' },
    'Unlikely' => { label: 'Unlikely match', css_class: 'confidence-unlikely', needle: 'M12.57 44.35L62.47 60.31L59.14 68.35L12.57 44.35Z' },
  }.freeze

  UNKNOWN_CONFIDENCE = { label: 'Unknown', css_class: 'confidence-unknown', needle: 'M68.55 10L68.55 60L68.55 60L68.55 10Z' }.freeze

  def render_confidence_meter(confidence)
    config = CONFIDENCE_LEVELS[confidence&.capitalize] || UNKNOWN_CONFIDENCE

    content_tag(:div, class: "confidence-indicator #{config[:css_class]}") do
      confidence_gauge_svg(config[:needle]) +
        content_tag(:span, config[:label], class: 'confidence-label')
    end
  end

  def confidence_gauge_svg(needle_path)
    content_tag(:svg, width: '100', height: '56', viewBox: '0 0 138 78', fill: 'none',
                      xmlns: 'http://www.w3.org/2000/svg', class: 'confidence-gauge',
                      aria: { label: 'Confidence gauge' }) do
      # Red section (left)
      content_tag(:path, nil, d: 'M33.78 34.49L19.72 20.43C7.64 32.69 0.14 49.48 0 68.02H19.88C20.01 54.97 25.29 43.15 33.78 34.49Z', fill: '#D4351C') +
        # Green section (right)
        content_tag(:path, nil, d: 'M117.17 68.02H137.05C136.91 49.48 129.41 32.69 117.33 20.43L103.27 34.49C111.75 43.15 117.03 54.97 117.17 68.02Z', fill: '#00703C') +
        # Yellow section (top right)
        content_tag(:path, nil, d: 'M69.03 0V19.88C82.09 20.01 93.91 25.28 102.57 33.77L116.63 19.71C104.37 7.63 87.57 0.13 69.03 0Z', fill: '#EADD00') +
        # Orange section (top left)
        content_tag(:path, nil, d: 'M34.48 33.78C43.14 25.29 54.96 20.02 68.02 19.89V0C49.47 0.13 32.68 7.63 20.42 19.72L34.48 33.78Z', fill: '#FF9F00') +
        # Center pivot
        content_tag(:circle, nil, cx: '68.55', cy: '67.52', r: '9.5', fill: 'black') +
        # Needle
        content_tag(:path, nil, d: needle_path, fill: 'black')
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
