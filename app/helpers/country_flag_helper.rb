module CountryFlagHelper
  def country_flag_emoji(two_letter_country_code)
    return unless two_letter_country_code.match? %r{\A[A-Z][A-Z]\z}

    # 127_397 offsets to the appropriate unicode values
    two_letter_country_code.codepoints.map { |codepoint| codepoint + 127_397 }.pack('U*')
  end

  def country_flag_tag(two_letter_country_code)
    flag = country_flag_emoji(two_letter_country_code)
    return unless flag

    tag.span(flag, class: 'country-flag')
  end
end
