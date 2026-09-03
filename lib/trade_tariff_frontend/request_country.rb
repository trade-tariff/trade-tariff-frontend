module TradeTariffFrontend
  module RequestCountry
    HEADER = 'CloudFront-Viewer-Country'.freeze
    COUNTRY_CODE_PATTERN = /\A[A-Z]{2}\z/

    module_function

    def normalize(value)
      country_code = value.to_s
      return '' if country_code == 'XX'

      country_code.match?(COUNTRY_CODE_PATTERN) ? country_code.downcase : ''
    end
  end
end
