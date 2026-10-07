module TradeTariffFrontend
  class ParcelGiftJourney
    ConfigurationError = Class.new(StandardError)

    INTERNAL_TARGETS = %w[commodity_search commodity_help].freeze
    ROOT_KEYS = %w[base_path feature_flag chooser homepage steps].freeze
    CHOOSER_KEYS = %w[route_name title error submit_label services fallback_heading fallback_text].freeze
    HOMEPAGE_KEYS = %w[title description].freeze
    STEP_KEYS = %w[id path route_name label title breadcrumb services sections].freeze
    SECTION_KEYS = %w[content details links].freeze
    DETAILS_KEYS = %w[summary content].freeze
    LINK_KEYS = %w[text target new_tab button prefix].freeze
    IDENTIFIER = /\A[a-z][a-z0-9_]*\z/
    SLUG = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
    GOVUK_URL = %r{\Ahttps://www\.gov\.uk/[A-Za-z0-9._~!$&'()*+,;=%/-]+\z}

    Chooser = Data.define(:route_name, :title, :error, :submit_label, :services, :fallback_heading, :fallback_text)
    Homepage = Data.define(:title, :description)
    Link = Data.define(:text, :target, :new_tab, :button, :prefix)
    Details = Data.define(:summary, :content)
    Section = Data.define(:content, :details, :links)
    Step = Data.define(:id, :path, :route_name, :label, :title, :breadcrumb, :services, :sections)

    def initialize(raw_config, service_names:)
      @service_names = normalize_service_names(service_names)
      load!(raw_config)
      freeze
    end

    attr_reader :base_path, :feature_flag, :chooser, :homepage, :steps

    def steps_for(service_name)
      name = service_name.to_s
      steps.select { |step| step.services.include?(name) }
    end

    def find_step(id, service_name:)
      step = @steps_by_id[id.to_s]
      step if step&.services&.include?(service_name.to_s)
    end

    private

    def load!(raw_config)
      config = object!(raw_config, 'configuration')
      unexpected!(config, ROOT_KEYS, 'configuration')
      @base_path = slug!(fetch!(config, 'base_path', 'configuration'), 'base_path')
      @feature_flag = identifier!(fetch!(config, 'feature_flag', 'configuration'), 'feature_flag')
      @chooser = build_chooser(fetch!(config, 'chooser', 'configuration'))
      @homepage = build_homepage(fetch!(config, 'homepage', 'configuration'))
      @steps = build_steps(fetch!(config, 'steps', 'configuration'))
      assert_distinct_names!
      @steps_by_id = @steps.index_by(&:id).freeze
    end

    def build_chooser(raw)
      chooser = object!(raw, 'chooser')
      unexpected!(chooser, CHOOSER_KEYS, 'chooser')
      Chooser.new(
        route_name: identifier!(fetch!(chooser, 'route_name', 'chooser'), 'chooser route_name'),
        title: text!(fetch!(chooser, 'title', 'chooser'), 'chooser title'),
        error: text!(fetch!(chooser, 'error', 'chooser'), 'chooser error'),
        submit_label: text!(fetch!(chooser, 'submit_label', 'chooser'), 'chooser submit_label'),
        services: services!(fetch!(chooser, 'services', 'chooser'), 'chooser services'),
        fallback_heading: text!(fetch!(chooser, 'fallback_heading', 'chooser'), 'chooser fallback_heading'),
        fallback_text: text!(fetch!(chooser, 'fallback_text', 'chooser'), 'chooser fallback_text'),
      ).freeze
    end

    def build_homepage(raw)
      homepage = object!(raw, 'homepage')
      unexpected!(homepage, HOMEPAGE_KEYS, 'homepage')
      Homepage.new(
        title: text!(fetch!(homepage, 'title', 'homepage'), 'homepage title'),
        description: text!(fetch!(homepage, 'description', 'homepage'), 'homepage description'),
      ).freeze
    end

    def build_steps(raw_steps)
      error!('steps', 'must be a list') unless raw_steps.is_a?(Array)
      error!('steps', 'must not be empty') if raw_steps.empty?

      raw_steps.map.with_index { |raw, index| build_step(raw, index) }.freeze.tap do |built|
        duplicate!(built.map(&:id), 'id')
        duplicate!(built.map(&:path), 'path')
        duplicate!(built.map(&:route_name), 'route_name')
      end
    end

    def build_step(raw, index)
      step = object!(raw, "step #{index}")
      unexpected!(step, STEP_KEYS, "step #{index}")
      context = "step #{index}"
      Step.new(
        id: identifier!(fetch!(step, 'id', context), "#{context} id"),
        path: slug!(fetch!(step, 'path', context), "#{context} path"),
        route_name: identifier!(fetch!(step, 'route_name', context), "#{context} route_name"),
        label: text!(fetch!(step, 'label', context), "#{context} label"),
        title: text!(fetch!(step, 'title', context), "#{context} title"),
        breadcrumb: text!(fetch!(step, 'breadcrumb', context), "#{context} breadcrumb"),
        services: services!(fetch!(step, 'services', context), "#{context} services"),
        sections: sections!(fetch!(step, 'sections', context), context),
      ).freeze
    end

    def sections!(raw_sections, context)
      error!(context, 'sections must be a non-empty list') unless raw_sections.is_a?(Array) && raw_sections.any?

      raw_sections.map.with_index { |raw, index|
        section_context = "#{context} section #{index}"
        section = object!(raw, section_context)
        unexpected!(section, SECTION_KEYS, section_context)
        error!(section_context, 'must not be empty') if section.empty?

        Section.new(
          content: section.key?('content') ? content!(section['content'], "#{section_context} content") : nil,
          details: section.key?('details') ? build_details(section['details'], section_context) : nil,
          links: links!(section.fetch('links', []), section_context),
        ).freeze
      }.freeze
    end

    def build_details(raw, context)
      details = object!(raw, "#{context} details")
      unexpected!(details, DETAILS_KEYS, "#{context} details")
      Details.new(
        summary: text!(fetch!(details, 'summary', context), "#{context} details summary"),
        content: content!(fetch!(details, 'content', context), "#{context} details content"),
      ).freeze
    end

    def links!(raw_links, context)
      error!("#{context} links", 'must be a list') unless raw_links.is_a?(Array)

      raw_links.map.with_index { |raw, index| build_link(raw, "#{context} link #{index}") }.freeze
    end

    def build_link(raw, context)
      link = object!(raw, context)
      unexpected!(link, LINK_KEYS, context)
      Link.new(
        text: text!(fetch!(link, 'text', context), "#{context} text"),
        target: target!(fetch!(link, 'target', context), "#{context} target"),
        new_tab: boolean!(fetch!(link, 'new_tab', context), "#{context} new_tab"),
        button: boolean!(fetch!(link, 'button', context), "#{context} button"),
        prefix: link.key?('prefix') ? text!(link['prefix'], "#{context} prefix") : nil,
      ).freeze
    end

    def assert_distinct_names!
      names = steps.flat_map { |step| [step.id, step.route_name] }
      return unless names.include?(chooser.route_name)

      error!('chooser route_name', 'must be distinct from step ids and route names')
    end

    def normalize_service_names(service_names)
      error!('service_names', 'must be a list') unless service_names.respond_to?(:map) && !service_names.is_a?(String)

      service_names.map { |name| service_name!(name) }.uniq.freeze.tap do |names|
        error!('service_names', 'must not be empty') if names.empty?
      end
    end

    def service_name!(name)
      error!('service_names', 'must be text') unless name.is_a?(String) || name.is_a?(Symbol)

      text = name.to_s.strip
      error!('service_names', 'must not be empty') if text.empty?

      text.freeze
    end

    def services!(value, context)
      error!(context, 'must be a list') unless value.is_a?(Array)

      names = value.map { |item| listed_service!(item, context) }
      error!(context, 'must not be empty') if names.empty?
      error!(context, 'contains a duplicate') unless names.uniq.size == names.size
      unknown = names - @service_names
      error!(context, "includes unsupported service #{unknown.first}") if unknown.any?

      names.freeze
    end

    def listed_service!(value, context)
      error!(context, 'must contain text') unless value.is_a?(String)

      text = value.strip
      error!(context, 'must not contain a blank service') if text.empty?

      text.freeze
    end

    def target!(value, context)
      text = text!(value, context)
      return text.freeze if INTERNAL_TARGETS.include?(text)

      govuk_target!(text, context)
    end

    def govuk_target!(text, context)
      error!(context, 'must be an allow-listed key or an https://www.gov.uk URL') unless text.match?(GOVUK_URL)
      path = text.delete_prefix('https://www.gov.uk')
      error!(context, 'must not include userinfo or path traversal') if path.include?('//') || path.include?('..')

      text.freeze
    end

    def content!(value, context)
      text = text!(value, context)
      error!(context, 'must be markdown without HTML, ERB, Ruby or URLs') if unsafe_content?(text)

      text.freeze
    end

    def unsafe_content?(text)
      text.match?(/[<>]|\#\{|\]\(|javascript:|https?:|^\s*\[[^\]]+\]:|^\s*#\s|^\s*=+\s*$/i)
    end

    def text!(value, context)
      error!(context, 'must be text') unless value.is_a?(String)

      text = value.strip
      error!(context, 'must not be empty') if text.empty?

      text.freeze
    end

    def identifier!(value, context)
      text = text!(value, context)
      error!(context, 'must be a lowercase snake_case identifier') unless text.length <= 64 && text.match?(IDENTIFIER)

      text.freeze
    end

    def slug!(value, context)
      text = text!(value, context)
      error!(context, 'must be a lowercase hyphenated slug') unless text.length <= 80 && text.match?(SLUG)

      text.freeze
    end

    def boolean!(value, context)
      error!(context, 'must be true or false') unless [true, false].include?(value)

      value
    end

    def object!(value, context)
      error!(context, 'must be a key-value object') unless value.respond_to?(:each_pair)

      value.to_h { |key, item| [key.to_s, item] }
    end

    def fetch!(hash, key, context)
      error!(context, "is missing #{key}") unless hash.key?(key)

      hash.fetch(key)
    end

    def unexpected!(hash, allowed, context)
      extra = hash.keys - allowed
      error!(context, "includes unknown key #{extra.first}") if extra.any?
    end

    def duplicate!(values, field)
      duplicate = values.tally.find { |_value, count| count > 1 }
      error!("field #{field}", "duplicates #{duplicate.first}") if duplicate
    end

    def error!(context, message)
      raise ConfigurationError, "#{context} #{message}"
    end
  end
end
