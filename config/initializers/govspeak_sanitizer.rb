# Govspeak sanitizer appears completely unconfigurable so resorting to monkey patching

module TariffGovspeakSanitizer
  def sanitize_config(...)
    orig_config = super

    Sanitize::Config.merge(
      orig_config,
      attributes: {
        'a' => orig_config[:attributes]['a'] + %w[target],
      },
    )
  end
end

Govspeak::HtmlSanitizer.prepend TariffGovspeakSanitizer
