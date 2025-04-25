module CountryFlagHelper
  def country_flag_tag(two_letter_country_code, **kwargs)
    two_letter_country_code = two_letter_country_code.downcase

    image_tag "flags/#{two_letter_country_code}.png",
              **kwargs.merge(class: 'country-flag')
  end
end
