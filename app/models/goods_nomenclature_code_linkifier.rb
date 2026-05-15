class GoodsNomenclatureCodeLinkifier
  Pattern = Data.define(:regexp, :code_from_match)

  SPACED_TERMINATORS = /(?=\s|;|,|$|\.|\)|\z)/
  PUNCTUATION_TERMINATORS = /(?=;|,|$|\)|\z|<br>|<\/br>)/
  COMBINED_TERMINATORS = /(?=\s|;|,|$|\.|\)|\z|<br>|<\/br>)/
  CODE_BOUNDARY_START = /(?<![A-Za-z0-9.\/-])/
  CODE_BOUNDARY_END = /(?![A-Za-z0-9.\/-])/
  HEADING_CODE = /(?:0[1-9]|[1-9]\d)(?:0[1-9]|[1-9]\d)/

  PATTERNS = [
    Pattern.new(/chapter\s+(\d{2})#{SPACED_TERMINATORS}/i, ->(match) { match[1] }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{4})\.(\d{2})#{SPACED_TERMINATORS}/, ->(match) { "#{match[1]}#{match[2]}" }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{4})\s(\d{2})\s(\d{2})#{SPACED_TERMINATORS}/, ->(match) { "#{match[1]}#{match[2]}#{match[3]}" }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{4})\s(\d{2})#{SPACED_TERMINATORS}/, ->(match) { "#{match[1]}#{match[2]}" }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{10}|\d{8}|\d{6})#{COMBINED_TERMINATORS}/, ->(match) { match[1] }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{10}|\d{8}|\d{6}|\d{2})#{CODE_BOUNDARY_END}/, ->(match) { match[1] }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{2})(?=\.\s|\.\z)/, ->(match) { match[1] }),
    Pattern.new(/\A(#{HEADING_CODE})#{SPACED_TERMINATORS}/, ->(match) { match[1] }),
    Pattern.new(/#{CODE_BOUNDARY_START}(#{HEADING_CODE})#{COMBINED_TERMINATORS}/, ->(match) { match[1] }),
  ].freeze

  def initialize(html, service_path: nil)
    @html = html.to_s
    @service_path = service_path || current_service_path
  end

  def render
    fragment = Nokogiri::HTML::DocumentFragment.parse(@html)

    fragment.xpath('.//text()[normalize-space()] | ./text()[normalize-space()]').each do |node|
      next if node.ancestors.any? { |ancestor| ancestor.name == 'a' }

      replacement = linkify_text(node.text)
      next if replacement == CGI.escapeHTML(node.text)

      node.replace(Nokogiri::HTML::DocumentFragment.parse(replacement))
    end

    fragment.to_html
  end

private

  def linkify_text(text)
    html = +''
    position = 0

    while position < text.length
      pattern, match = next_match(text, position)

      unless match
        html << CGI.escapeHTML(text[position..])
        break
      end

      html << CGI.escapeHTML(text[position...match.begin(0)])
      html << link_for(match[0], pattern.code_from_match.call(match))
      position = match.end(0)
    end

    html
  end

  def next_match(text, position)
    PATTERNS.each_with_object([nil, nil]) do |pattern, best|
      match = pattern.regexp.match(text, position)
      next unless match

      if best[1].nil? || match.begin(0) < best[1].begin(0)
        best[0] = pattern
        best[1] = match
      end
    end
  end

  def link_for(text, code)
    href = "#{@service_path}/search?#{Rack::Utils.build_query(q: code)}"
    link_text = %(#{CGI.escapeHTML(text)}<span class="govuk-visually-hidden"> (opens in new tab)</span>)

    %(<a class="govuk-link" href="#{CGI.escapeHTML(href)}" rel="noopener noreferrer" target="_blank">#{link_text}</a>)
  end

  def current_service_path
    TradeTariffFrontend::ServiceChooser.xi? ? '/xi' : ''
  end
end
