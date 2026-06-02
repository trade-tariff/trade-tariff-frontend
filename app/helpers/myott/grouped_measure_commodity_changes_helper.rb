module Myott
  module GroupedMeasureCommodityChangesHelper
    def commodity_change_link(goods_nomenclature_item_id, change)
      govuk_link_to(
        commodity_change_link_text(change),
        commodity_path(goods_nomenclature_item_id, **change.commodity_link_params),
        target: '_blank',
        rel: 'noopener',
        visually_hidden_suffix: Govuk::Components.config.default_link_new_tab_text,
      )
    end

    def commodity_change_link_text(change)
      date_of_effect_visible = change.date_of_effect_visible
      return 'View commodity' if date_of_effect_visible.blank?

      "View commodity on #{date_of_effect_visible}"
    end
  end
end
