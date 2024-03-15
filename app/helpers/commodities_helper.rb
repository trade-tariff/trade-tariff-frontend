module CommoditiesHelper
  def footnote_heading(declarable)
    t('tabs.footnote.heading', goods_nomenclature_item_id: declarable.id, declarable_type: declarable.model_name.singular)
  end

  def leaf_position(commodity)
    if commodity.last_child?
      ' last-child'
    end
  end

  def commodity_level(commodity, initial_indent)
    initial_indent ||= 1
    normalized_indent = commodity.number_indents - initial_indent + 1

    "level-#{normalized_indent}"
  end

  def tree_code(code, klass: 'full-code')
    "<div class='#{klass}'>
      #{chapter_and_heading_codes(code)}
      <div class='commodity-code'>
        #{code_text(code[4..5])}
        #{code_text(code[6..7])}
        #{code_text(code[8..9])}
      </div>
    </div>".html_safe
  end

  def format_full_code(commodity)
    code = commodity.code.to_s
    tree_code(code, klass: nil)
  end

  def format_commodity_code(commodity)
    code = commodity.display_short_code.to_s
    "#{code[0..1]}&nbsp;#{code[2..3]}&nbsp;#{code[4..]}".html_safe
  end

  def format_commodity_code_based_on_level(commodity)
    code = commodity.code.to_s
    display_full_code = commodity.producline_suffix == '80'

    if commodity.number_indents > 1 || display_full_code
      # remove trailing pairs of zeros for non declarable
      code = code.gsub(/0{2}+$/, '') if commodity.has_children?
      tree_code(code, klass: nil)
    end
  end

  def convert_text_to_links(text)
    starting_characters = /(\s|^|\A|<br>|<\/br>)/
    terminating_characters = /(\s|;|,|$|\.|\z|<br>|<\/br>)/

    text = text.gsub( # Match subheading longer-syntax
      /#{starting_characters}(\d{4})\s(\d{2})\s(\d{2})#{terminating_characters}/,
      " <a href='/search?q=\\2\\3\\4#{query}'>\\2 \\3 \\4</a>\\5",
    )
    text = text.gsub( # Match subheading short syntax
      /#{starting_characters}(\d{4})\s(\d{2})#{terminating_characters}/,
      " <a href='/search?q=\\2\\3#{query}'>\\2 \\3</a>\\4",
    )
    text = text.gsub( # Match heading short syntax
      /#{starting_characters}(\d{4})#{terminating_characters}/,
      " <a href='/search?q=\\2#{query}'>\\2</a>\\3",
    )
    text.gsub( # Match chapter short syntax
      /(chapter)\s(\d{2})#{terminating_characters}/i,
      "<a href='/search?q=\\2#{query}'>\\1 \\2</a>\\3",
    )
  end

  def query
    applicable_query_params = url_options.slice(:year, :month, :day, :country)

    applicable_query_params.any? ? "&#{applicable_query_params.to_query}" : ''
  end

  def overview_measure_duty_amounts_for(commodity)
    content_tag(:div, data: { tree_target: 'commodityInfo' }, class: 'commodity__info') do
      if TradeTariffFrontend::ServiceChooser.uk?
        concat(content_tag(:div, vat_overview_measure_duty_amounts(commodity), class: 'vat', aria: { describedby: 'commodity-vat-title' }))
      end

      concat(
        content_tag(
          :div,
          third_country_overview_measure_duty_amounts(commodity),
          class: 'duty',
          aria: { describedby: 'commodity-duty-title' },
        ),
      )

      concat(
        content_tag(
          :div,
          supplementary_unit_overview_measure_duty_amounts(commodity),
          class: 'supplementary-units',
          aria: { describedby: 'commodity-supplementary-title' },
        ),
      )

      concat(
        content_tag(
          :div,
          segmented_commodity_code(abbreviate_commodity_code(commodity), coloured: true),
          class: "identifier service-#{TradeTariffFrontend::ServiceChooser.service_name}",
          aria: { describedby: "commodity-#{commodity.short_code}" },
        ),
      )
    end
  end

  def vat_overview_measure_duty_amounts(commodity)
    vat_overview_measures = commodity.overview_measures.vat

    duty_amounts = vat_overview_measures.map do |vat_measure|
      "#{vat_measure.amount}%"
    end

    safe_join(duty_amounts, ' or ').presence || '&nbsp;'.html_safe
  end

  def third_country_overview_measure_duty_amounts(commodity)
    measures = commodity.overview_measures.third_country_duties
    additional_code_measures = measures.with_additional_code

    if additional_code_measures.none? && measures.any?
      duty_amounts = measures.unique_third_country_overview_measures.map do |measure|
        measure.duty_expression.formatted_base
      end

      duty_amounts.join('<br />').html_safe
    elsif measures.many?
      render('commodities/additional_code_table', measures:)
    else
      '&nbsp;'.html_safe
    end
  end

  def supplementary_unit_overview_measure_duty_amounts(commodity)
    measures = commodity.overview_measures.supplementary

    if measures.length.positive?
      duty_amounts = measures.map { |m| m.duty_expression.formatted_base }
      duty_amounts.uniq.join('<br />').html_safe
    else
      '&nbsp;'.html_safe
    end
  end

  def sanitize_quotes(text)
    text.gsub(/[\u2018\u2019]/, "'") # Replace left and right single quotes
        .gsub(/[\u201C\u201D]/, '"') # Replace left and right double quotes
  end

  private

  def chapter_and_heading_codes(code)
    "<div class='chapter-code'>
      #{code_text(code[0..1])}
    </div>
    <div class='heading-code'>
      #{code_text(code[2..3])}
    </div>".html_safe
  end

  def code_text(code)
    str = code || '&nbsp;'
    "<div class='code-text pull-left'>#{str}</div>"
  end

  def tree_node(main_commodity, commodities, depth)
    deeper_node = commodities.select { |c| c.number_indents == depth + 1 }.first
    if deeper_node.present? && deeper_node.number_indents < main_commodity.number_indents
      tag.ul do
        tag.li do
          tree_code(deeper_node.code.gsub(/0{2}+$/, '')) +
            tag.p(deeper_node.to_s.html_safe) +
            tree_node(main_commodity, commodities, deeper_node.number_indents)
        end
      end
    else
      tag.ul do
        commodity_heading(main_commodity)
      end
    end
  end

  def commodity_heading(commodity)
    tag.li(class: 'commodity-li') do
      tag.div(title: "Full tariff code: #{commodity.code}",
              class: 'commodity-code',
              'aria-describedby' => "commodity-#{commodity.code}") do
                tag.div(format_commodity_code(commodity), class: 'code-text')
              end
      tree_commodity_code(commodity) + tag.p(commodity.to_s.html_safe)
    end
  end

  def commodity_heading_full(commodity)
    tag.li(class: 'commodity-li') do
      tag.div(title: "Full tariff code: #{commodity.code}",
              class: 'full-code',
              'aria-describedby' => "commodity-#{commodity.code}") do
                tag.div(format_full_code(commodity), class: 'code-text')
              end
      tag.p(commodity.to_s.html_safe)
    end
  end

  def declarable_heading_full(commodity)
    tag.li(class: 'commodity-li') do
      tag.div(format_full_code(commodity),
              title: "Full tariff code: #{commodity.code}",
              class: 'full-code',
              'aria-describedby' => "commodity-#{commodity.code}") +
        tag.p(commodity.to_s.html_safe)
    end
  end

  def segmented_commodity_code(code, coloured: false)
    parts = divide_commodity_code(code)
    return unless parts

    css_classes = %w[segmented-commodity-code]
    css_classes << 'segmented-commodity-code--coloured' if coloured

    tag.span class: css_classes.join(' ') do
      safe_join parts.map(&tag.method(:span))
    end
  end

  def divide_commodity_code(code)
    return if code.blank?

    code.to_s.gsub(/[^\d]/, '').split('').each_slice(4).map(&:join)
  end

  def abbreviate_commodity_code(commodity)
    code = commodity.code.to_s

    commodity.declarable? ? code : abbreviate_code(code)
  end

  def abbreviate_code(code)
    only_code = code_without_subheading(code)

    case only_code.gsub(/0*\z/, '').length
    when 9..10
      only_code
    when 7..8
      only_code.slice(0, 8)
    when 5..6
      only_code.slice(0, 6)
    else
      only_code
    end
  end

  def commodity_ancestor_id(index)
    "commodity-ancestors__ancestor-#{index}"
  end

  def code_without_subheading(code)
    code.split('-').first
  end
end
