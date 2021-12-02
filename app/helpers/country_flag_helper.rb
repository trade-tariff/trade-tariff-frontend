module CountryFlagHelper
  COUNTRY_FLAG_IGNORE = %w[xi xc xl].freeze

  def country_flag_tag(two_letter_country_code, **kwargs)
    two_letter_country_code = two_letter_country_code.downcase

    image_pack_tag "flags/#{two_letter_country_code}.png",
                   **kwargs.merge(class: 'country-flag')
  rescue Webpacker::Manifest::MissingEntryError
    unless CountryFlagHelper::COUNTRY_FLAG_IGNORE.include?(two_letter_country_code)
      Sentry.capture_message \
        "Missing flag image file for #{two_letter_country_code}"
    end

    nil
  end
end
