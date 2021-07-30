module CountryFlagHelper
  def country_flag(iso_2_code)
    # 127_397 offsets to the appropriate unicode values
    iso_2_code.codepoints.map { |codepoint| codepoint + 127_397 }.pack('U*')
  end
end
  
