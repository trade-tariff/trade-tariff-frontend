module CountryFlagHelper
  def country_flag_tag(two_letter_country_code, **kwargs)
    image_pack_tag "flags/#{two_letter_country_code.downcase}.png",
                   **kwargs.merge(class: 'country-flag')
  rescue Webpacker::Manifest::MissingEntryError
    Raven.capture_message \
      "Missing flag image file for #{two_letter_country_code.downcase}"

    nil
  end
end
