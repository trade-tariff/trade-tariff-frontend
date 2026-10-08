module ParcelGiftJourneyHelper
  def parcel_gift_chooser_path
    public_send("#{Rails.configuration.parcel_gift_journey.chooser.route_name}_path")
  end

  def parcel_gift_link(link)
    destination = case link.target
                  when 'commodity_search' then find_commodity_path(search_mode: 'guided', anchor: 'new_search')
                  when 'commodity_help' then help_find_commodity_path
                  else link.target
                  end
    options = link.new_tab ? { target: '_blank', rel: 'noopener' } : {}
    text = link.new_tab ? "#{link.text} (opens in new tab)" : link.text

    if link.button
      govuk_button_link_to(text, destination, **options)
    else
      govuk_link_to(text, destination, **options)
    end
  end
end
