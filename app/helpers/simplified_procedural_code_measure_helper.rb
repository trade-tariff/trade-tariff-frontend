module SimplifiedProceduralCodeMeasureHelper
  def date_range_message(validity_start_date, validity_end_date)
    "#{validity_start_date.to_date.to_formatted_s(:long)} to #{validity_end_date.to_date.to_formatted_s(:long)}"
  end

  def simplified_procedural_code_page_title(by_code, simplified_procedural_code, goods_nomenclature_label)
    if by_code
      "Simplified procedure value rates for code #{simplified_procedural_code} - #{goods_nomenclature_label}"
    else
      'Check simplified procedure value rates for fresh fruit and vegetables'
    end
  end

  def goods_nomenclature_item_id_links_for(goods_nomenclature_item_ids)
    links = goods_nomenclature_item_ids.split(',').map do |goods_nomenclature_item_id|
      item_id = goods_nomenclature_item_id.strip
      link_to item_id, commodity_path(item_id)
    end

    safe_join(links, ', ')
  end

  def presented_duty_amount(simplified_procedural_code_measure)
    duty_amount = simplified_procedural_code_measure.duty_amount
    presented_monetary_unit = simplified_procedural_code_measure.presented_monetary_unit

    if duty_amount
      presented_amount = number_with_precision duty_amount, precision: 2, delimiter: ','
      "#{presented_monetary_unit}#{presented_amount}"
    else
      '—'
    end
  end
end
