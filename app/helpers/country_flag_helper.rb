module CountryFlagHelper
  def country_flag_emoji(two_letter_country_code)
    # 127_397 offsets to the appropriate unicode values
    two_letter_country_code.codepoints.map { |codepoint| codepoint + 127_397 }.pack('U*')
  end

  def country_flag_tag(two_letter_country_code)
    tag.span(country_flag_emoji(two_letter_country_code), class: 'country-flag')
  end
end
