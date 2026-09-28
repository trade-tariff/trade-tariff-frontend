require 'json'

# Emits one low-cardinality Embedded Metric Format line per eligible HTML
# request. CloudWatch extracts the counters from stdout. A dropped write must
# not affect the request. Session IDs, request IDs, paths and user agents are
# never metric dimensions.
#
# Eligibility and labels come from data/page_visit_catalogue.json, which the
# page-visits dashboard reads as well. A repeated log line can still double-count
# a metric; the session log widgets continue to collapse duplicate request IDs.
class PageVisitMetrics
  CATALOGUE_PATH = File.expand_path('../data/page_visit_catalogue.json', __dir__)
  MAX_LINE_BYTES = 4096
  private_constant :MAX_LINE_BYTES

  class << self
    def subscribe!(output: $stdout, environment: TradeTariffFrontend.environment)
      unsubscribe!
      @subscriber = ActiveSupport::Notifications.subscribe('process_action.action_controller') do |*args|
        record(ActiveSupport::Notifications::Event.new(*args), output:, environment:)
      end
    end

    def unsubscribe!
      return unless @subscriber

      ActiveSupport::Notifications.unsubscribe(@subscriber)
      @subscriber = nil
    end

    def record(event, output: $stdout, environment: TradeTariffFrontend.environment, catalogue: self.catalogue)
      request_id = event.payload[:request_id].to_s
      return false if request_id.empty? || already_recorded?(request_id)

      line = line_for(event.payload, environment:, catalogue:, now: event.end)
      return false unless line

      written = output.write_nonblock(line, exception: false) == line.bytesize
      remember_request(request_id) if written
      written
    rescue StandardError
      false
    end

    def line_for(payload, environment:, now:, catalogue: self.catalogue)
      sample = sample_for(payload, environment:, catalogue:, now:)
      return if sample.nil?

      line = "#{JSON.generate(sample)}\n"
      return if line.bytesize > MAX_LINE_BYTES

      line
    end

    def catalogue
      @catalogue ||= JSON.parse(File.read(CATALOGUE_PATH))
    end

    private

    def already_recorded?(request_id)
      Thread.current[:page_visit_metrics_request_id] == request_id
    end

    def remember_request(request_id)
      Thread.current[:page_visit_metrics_request_id] = request_id
    end

    def sample_for(payload, environment:, catalogue:, now:)
      request = Request.new(payload)
      return unless request.eligible?(catalogue)

      classification = Classification.new(request, catalogue)
      properties = {
        event: 'page_visit.metrics',
        Environment: environment,
        Service: catalogue.fetch('service'),
        Activity: classification.activity_label,
        SessionCoverage: classification.coverage,
        StatusClass: classification.status_label,
        Page: classification.page_label,
        PageMapping: classification.mapping,
        catalogue.fetch('metric') => 1,
      }
      directives = [
        %w[Environment Service Activity],
        %w[Environment Service SessionCoverage],
        %w[Environment Service StatusClass],
        %w[Environment Service Page],
        %w[Environment Service PageMapping],
      ]
      if classification.tariff_page
        properties[:TariffPage] = classification.tariff_page
        directives << %w[Environment Service TariffPage]
      end
      properties[:_aws] = {
        Timestamp: (now.to_f * 1000).to_i,
        CloudWatchMetrics: directives.map { |dimensions| metric_directive(catalogue, dimensions) },
      }
      properties
    end

    def metric_directive(catalogue, dimensions)
      {
        Namespace: catalogue.fetch('namespace'),
        Dimensions: [dimensions],
        Metrics: [{ Name: catalogue.fetch('metric'), Unit: 'Count' }],
      }
    end
  end

  class Request
    attr_reader :controller, :action, :method, :path, :status, :format, :request_id, :session_id, :user_agent

    def initialize(payload)
      @controller = payload[:controller].to_s
      @action = payload[:action].to_s
      @method = payload[:method].to_s.upcase
      @path = payload[:path].to_s
      @status = payload[:status]
      @format = payload[:format].to_s
      @request_id = payload[:request_id].to_s
      @session_id = payload[:browser_session_id].to_s
      @user_agent = payload[:user_agent].to_s
    end

    def eligible?(catalogue)
      format == 'html' && !controller.empty? && status.is_a?(Integer) && !request_id.empty? &&
        !controller.match?(catalogue.fetch('excluded_controller_pattern')) &&
        (user_agent.empty? || !user_agent.downcase.match?(catalogue.fetch('bot_pattern')))
    end

    def page_key
      "#{controller}##{action}"
    end
  end

  class Classification
    def initialize(request, catalogue)
      @request = request
      @catalogue = catalogue
    end

    def activity_label
      activity.fetch('label')
    end

    def coverage
      @catalogue.fetch('coverage').fetch(@request.session_id.empty? ? 'missing' : 'present')
    end

    def status_label
      status = @catalogue.fetch('statuses').find { |candidate| @request.status >= candidate.fetch('minimum') }
      status.fetch('label')
    end

    def page_label
      label = page_name
      label += ' (form submission)' unless %w[GET HEAD].include?(@request.method)
      label += ' (redirect)' if @request.status >= 300 && @request.status < 400
      label
    end

    def mapping
      unmapped = [fallbacks.fetch('unmapped'), fallbacks.fetch('enquiry_unmapped_step')]
      @catalogue.fetch('mapping').fetch(unmapped.include?(page_name) ? 'unmapped' : 'mapped')
    end

    def tariff_page
      return unless @catalogue.fetch('tariff_keys').include?(@request.page_key)

      @catalogue.fetch('page_names').fetch(@request.page_key).fetch('name')
    end

    private

    def activity
      @activity ||= matched_activity || default_activity
    end

    def matched_activity
      @catalogue.fetch('activities').find { |candidate| matches?(candidate) }
    end

    def default_activity
      @catalogue.fetch('activities').find { |candidate| candidate.fetch('matchers').empty? }
    end

    def matches?(candidate)
      candidate.fetch('matchers').any? { |matcher| matcher_matches?(matcher) }
    end

    def matcher_matches?(matcher)
      values = matcher.fetch('values')
      case matcher.fetch('type')
      when 'page_key' then values.include?(@request.page_key)
      when 'controller' then values.include?(@request.controller)
      when 'controller_prefix' then values.any? { |prefix| @request.controller.start_with?(prefix) }
      else false
      end
    end

    def enquiry_step_label
      return unless @request.controller == 'ProductExperience::EnquiryFormController' && %w[form submit].include?(@request.action)

      step = @request.path[%r{\A/(?:uk/|xi/)?enquiry_form/(?<enquiry_step>[^/?]+)(?:\?.*)?\z}, :enquiry_step]
      name = @catalogue.fetch('enquiry_steps')[step]
      return "Enquiry: #{name}" if name

      fallbacks.fetch('enquiry_unmapped_step')
    end

    def named_page
      @catalogue.fetch('page_names').dig(@request.page_key, 'name')
    end

    def page_name
      enquiry_step_label || named_page || fallback_label
    end

    def fallback_label
      controller = @request.controller
      return fallbacks.fetch('duty_calculator') if controller.start_with?('DutyCalculator::')
      return fallbacks.fetch('rules_of_origin') if controller.start_with?('RulesOfOrigin::')
      return fallbacks.fetch('green_lanes') if controller.start_with?('GreenLanes::')
      return fallbacks.fetch('enquiry') if controller == 'ProductExperience::EnquiryFormController'

      fallbacks.fetch('unmapped')
    end

    def fallbacks
      @catalogue.fetch('fallbacks')
    end
  end
end
