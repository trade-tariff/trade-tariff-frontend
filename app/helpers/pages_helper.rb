module PagesHelper
  def cn2021_cn2022_8_digit_file
    file = 'public/cn2021_2022/CorrelationCN2021toCN2022Rev21Oct.xls'
    asset = 'cn2021_2022/CorrelationCN2021toCN2022Rev21Oct.xls'
    asset_size = number_to_human_size(File.size(file))
    link_text = 'Download UK Goods classification 2021 to 2022 correlation table (changes to 8-digit commodity codes)'

    [asset, asset_size, link_text]
  end

  private

  def chapter_for(short_code, chapters)
    goods_nomenclature_item_id = "#{short_code}00000000"

    chapters.find { |chapter| chapter.goods_nomenclature_item_id == goods_nomenclature_item_id }
  end
end
