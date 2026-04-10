class DeclarablePresenter < TradeTariffFrontend::Presenter
  def to_s
    formatted_description.html_safe
  end

  def self.model_name
    name.chomp('Presenter').constantize.model_name
  end

  def footnote_heading
    I18n.t('tabs.footnote.heading', goods_nomenclature_item_id: id, declarable_type: model_name.singular)
  end

  def format_full_code
    tree_code(code.to_s, klass: nil)
  end

  def format_commodity_code
    short = display_short_code.to_s
    "#{short[0..1]}&nbsp;#{short[2..3]}&nbsp;#{short[4..]}".html_safe
  end

  def format_commodity_code_based_on_level
    commodity_code = code.to_s
    display_full_code = producline_suffix == '80'

    if number_indents > 1 || display_full_code
      commodity_code = commodity_code.gsub(/0{2}+$/, '') if has_children?
      tree_code(commodity_code, klass: nil)
    end
  end

  def abbreviate_commodity_code
    commodity_code = code.to_s
    declarable? ? commodity_code : abbreviate_code(commodity_code)
  end

  private

  def tree_code(commodity_code, klass: 'full-code')
    "<div class='#{klass}'>
      #{chapter_and_heading_codes(commodity_code)}
      <div class='commodity-code'>
        #{code_text(commodity_code[4..5])}
        #{code_text(commodity_code[6..7])}
        #{code_text(commodity_code[8..9])}
      </div>
    </div>".html_safe
  end

  def chapter_and_heading_codes(commodity_code)
    "<div class='chapter-code'>
      #{code_text(commodity_code[0..1])}
    </div>
    <div class='heading-code'>
      #{code_text(commodity_code[2..3])}
    </div>".html_safe
  end

  def code_text(segment)
    str = segment || '&nbsp;'
    "<div class='code-text pull-left'>#{str}</div>"
  end

  def abbreviate_code(commodity_code)
    only_code = commodity_code.split('-').first

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
end
