module CommoditiesHelper
  def commodity_code
    (@commodity || @heading).code
  end

  def footnote_heading(declarable)
    t('tabs.footnote.heading', goods_nomenclature_item_id: declarable.id, declarable_type: declarable.model_name.singular)
  end

  def leaf_position(commodity)
    if commodity.last_child?
      ' last-child'
    end
  end

  def commodity_level(commodity)
    "level-#{commodity.number_indents}"
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

  def segmented_commodity_code(code)
    return if code.blank?

    parts = code.to_s.gsub(/[^\d]/, '').split('').each_slice(4).map(&:join)

    tag.span class: 'segmented-commodity-code' do
      safe_join parts.map(&tag.method(:span))
    end
  end
end
