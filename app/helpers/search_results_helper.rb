module SearchResultsHelper
  CONFIDENCE_LEVELS = {
    'Strong' => { label: 'Strong result', css_class: 'confidence-strong', needle: 'M118.78 38.52L77.73 67.42L73.23 59.62Z' },
    'Good' => { label: 'Good result', css_class: 'confidence-good', needle: 'M68.55 9.52L73.05 59.52L64.05 59.52Z' },
    'Possible' => { label: 'Possible result', css_class: 'confidence-possible', needle: 'M18.32 38.52L63.87 59.62L59.37 67.42Z' },
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
      # Orange, yellow and green each fill one third of the semicircle.
      content_tag(:path, nil, d: 'M0.53 68.02A68.02 68.02 0 0 1 32.5 10.34L43.04 27.19A48.14 48.14 0 0 0 20.41 68.02Z', fill: '#FF9F00', data: { confidence_segment: true }) +
        # Yellow section (centre)
        content_tag(:path, nil, d: 'M36.62 7.96A68.02 68.02 0 0 1 100.48 7.96L91.15 25.51A48.14 48.14 0 0 0 45.95 25.51Z', fill: '#EADD00', data: { confidence_segment: true }) +
        # Green section (right)
        content_tag(:path, nil, d: 'M104.6 10.34A68.02 68.02 0 0 1 136.57 68.02L116.69 68.02A48.14 48.14 0 0 0 94.06 27.19Z', fill: '#00703C', data: { confidence_segment: true }) +
        # Needle
        content_tag(:path, nil, d: needle_path, fill: 'black') +
        # Center pivot
        content_tag(:circle, nil, cx: '68.55', cy: '67.52', r: '9.5', fill: 'black')
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
