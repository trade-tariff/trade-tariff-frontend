module CountryFlagHelper
  def country_flag_tag(two_letter_country_code, **kwargs)
    image_pack_tag "flags/#{two_letter_country_code.downcase}.png",
                   **kwargs.merge(class: 'country-flag')
  end
end
