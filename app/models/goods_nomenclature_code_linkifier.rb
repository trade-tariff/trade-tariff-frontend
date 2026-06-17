class GoodsNomenclatureCodeLinkifier
  Pattern = Data.define(:regexp, :code_from_match)

  CODE_SPACE = /(?:\s|\u00A0)/
  SPACED_TERMINATORS = /(?=#{CODE_SPACE}|;|,|:|$|\.|\)|\z)/
  COMBINED_TERMINATORS = /(?=#{CODE_SPACE}|;|,|:|$|\.|\)|\z|<br>|<\/br>)/
  CODE_BOUNDARY_START = /(?<![A-Za-z0-9.\/-])/
  CODE_BOUNDARY_END = /(?![A-Za-z0-9.\/-])/
  HEADING_CODE = /(?:0[1-9]|[1-9]\d)(?:0[1-9]|[1-9]\d)/
  CHAPTER_CONTINUATION = Pattern.new(/#{CODE_BOUNDARY_START}(\d{1,2})#{SPACED_TERMINATORS}/, ->(match) { match[1].rjust(2, '0') })

  PATTERNS = [
    Pattern.new(/(?<=\bchapter )(\d{1,2})#{SPACED_TERMINATORS}/i, ->(match) { match[1].rjust(2, '0') }),
    Pattern.new(/(?<=\bchapter\u00A0)(\d{1,2})#{SPACED_TERMINATORS}/i, ->(match) { match[1].rjust(2, '0') }),
    Pattern.new(/(?<=\bchapters )(\d{1,2})#{SPACED_TERMINATORS}/i, ->(match) { match[1].rjust(2, '0') }),
    Pattern.new(/(?<=\bchapters\u00A0)(\d{1,2})#{SPACED_TERMINATORS}/i, ->(match) { match[1].rjust(2, '0') }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{4})\.(\d{2})#{SPACED_TERMINATORS}/, ->(match) { "#{match[1]}#{match[2]}" }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{4})#{CODE_SPACE}(\d{4})#{CODE_SPACE}(\d{2})#{SPACED_TERMINATORS}/, ->(match) { "#{match[1]}#{match[2]}#{match[3]}" }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{4})#{CODE_SPACE}(\d{2})#{CODE_SPACE}(\d{2})#{CODE_SPACE}(\d{2})#{SPACED_TERMINATORS}/, ->(match) { "#{match[1]}#{match[2]}#{match[3]}#{match[4]}" }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{4})#{CODE_SPACE}(\d{4})#{SPACED_TERMINATORS}/, ->(match) { "#{match[1]}#{match[2]}" }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{4})#{CODE_SPACE}(\d{2})#{CODE_SPACE}(\d{2})#{SPACED_TERMINATORS}/, ->(match) { "#{match[1]}#{match[2]}#{match[3]}" }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{4})#{CODE_SPACE}(\d{2})#{SPACED_TERMINATORS}/, ->(match) { "#{match[1]}#{match[2]}" }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{10}|\d{8}|\d{6})#{COMBINED_TERMINATORS}/, ->(match) { match[1] }),
    Pattern.new(/#{CODE_BOUNDARY_START}(\d{10}|\d{8}|\d{6})#{CODE_BOUNDARY_END}/, ->(match) { match[1] }),
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
    best = PATTERNS.each_with_object([nil, nil]) do |pattern, candidate|
      match = pattern.regexp.match(text, position)
      next unless match
      next unless linkifiable_match?(text, match, pattern)

      if candidate[1].nil? || match.begin(0) < candidate[1].begin(0)
        candidate[0] = pattern
        candidate[1] = match
      end
    end

    chapter_continuation = next_chapter_continuation_match(text, position)
    if chapter_continuation && (best[1].nil? || chapter_continuation.begin(0) < best[1].begin(0))
      best = [CHAPTER_CONTINUATION, chapter_continuation]
    end

    best
  end

  def next_chapter_continuation_match(text, position)
    offset = position

    while (match = CHAPTER_CONTINUATION.regexp.match(text, offset))
      return match if chapter_continuation?(text, match.begin(0))

      offset = match.end(0)
    end
  end

  def chapter_continuation?(text, position)
    context = text[[position - 120, 0].max...position].to_s
    context = context.split(/[.;:()\n]/).last.to_s

    context.match?(/\bchapters?\s+\d{1,2}(?:\s*(?:,|to|or|and)\s*\d{1,2})*\s*(?:,|to|or|and)\s*\z/i)
  end

  def linkifiable_match?(text, match, pattern)
    code = pattern.code_from_match.call(match)
    return true unless code.match?(/\A\d{4}\z/)

    before = text[[match.begin(0) - 60, 0].max...match.begin(0)].to_s
    after = text[match.end(0), 40].to_s

    return false if standard_reference_context?(before)
    return false if code.match?(/\A(?:19|20)\d{2}\z/) && !explicit_code_context?(before)
    return false if before.end_with?(':') && text[[match.begin(0) - 20, 0].max...match.begin(0)].to_s.match?(/\bISO\s+\d{4}:\z/i)
    return false if after.match?(/\A\s*(?:method|methods)\b/i) && before.match?(/\b(?:ISO|EN ISO|ASTM D|Standard)\s*\z/i)

    true
  end

  def standard_reference_context?(before)
    before.match?(/\b(?:ISO|EN ISO|ASTM D|Standard)\s*\z/i)
  end

  def explicit_code_context?(before)
    before.match?(/\b(?:heading|headings|subheading|subheadings|code|codes)\s+(?:\d{4}(?:\s+\d{2,4})*(?:\s*(?:,|to|or|and)\s*)?)*\z/i)
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
