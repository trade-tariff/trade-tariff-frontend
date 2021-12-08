module PagesHelper
  def cn2021_cn2022_10_digit_files(chapters)
    Dir.glob('public/cn2021_2022/2022 10 digit codes*').map do |file|
      asset              = file.gsub('public/', '')
      asset_size         = number_to_human_size(File.size(file))
      chapter_short_code = file.match(%r{Chapter (?<chapter_id>\d{2})})[:chapter_id]
      chapter            = chapter_for(chapter_short_code, chapters)
      link_text          = "Chapter #{chapter_short_code} - #{chapter} (2022 10-digit changes)"

      [asset, asset_size, link_text]
    end
  end

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
