module PagesHelper
  def cn2021_cn2022_8_digit_file
    asset = 'CorrelationCN2021toCN2022Rev21Oct.xls'
    asset_size = '127 KB'
    link_text = 'Download UK Goods classification 2021 to 2022 correlation table (changes to 8-digit commodity codes)'

    [asset, asset_size, link_text]
  end

  def help_guide_links
    content_tag(:ul, class: 'govuk-list govuk-list--bullet') do
      safe_join(
        Rails.application.config.guide_links.map do |link_text, url|
          content_tag(:li) do
            link_to link_text, url, class: 'gem-c-contents-list__link govuk-link govuk-link--no-underline', target: '_blank', rel: 'noopener'
          end
        end,
      )
    end
  end

  private

  def chapter_for(short_code, chapters)
    goods_nomenclature_item_id = "#{short_code}00000000"

    chapters.find { |chapter| chapter.goods_nomenclature_item_id == goods_nomenclature_item_id }
  end
end
