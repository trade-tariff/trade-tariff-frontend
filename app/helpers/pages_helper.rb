module PagesHelper
  def cn2021_cn2022_8_digit_file
    asset = 'CorrelationCN2021toCN2022Rev21Oct.xls'
    asset_size = '127 KB'
    link_text = 'Download UK Goods classification 2021 to 2022 correlation table (changes to 8-digit commodity codes)'

    [asset, asset_size, link_text]
  end

  private

  def chapter_for(short_code, chapters)
    goods_nomenclature_item_id = "#{short_code}#{GoodsNomenclature::CHAPTER_SUFFIX}"

    chapters.find { |chapter| chapter.goods_nomenclature_item_id == goods_nomenclature_item_id }
  end
end
