module CountryFlagHelper
  def country_flag_emoji(iso_2_code)
    # 127_397 offsets to the appropriate unicode values
    iso_2_code.codepoints.map { |codepoint| codepoint + 127_397 }.pack('U*')
  end

  def country_flag_tag(iso_2_code)
    tag.span(country_flag_emoji(iso_2_code), class: 'country-flag')
  end
end
