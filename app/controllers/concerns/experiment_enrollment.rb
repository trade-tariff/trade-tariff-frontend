module ExperimentEnrollment
  private

  def enroll_in_experiment(experiment, at: Time.current)
    enrolled = valid_experiment_enrollments(at:)
    tokens = enrolled.map(&:enrollment_token) - [experiment.enrollment_token]
    session[:experiment_url_optins] = tokens << experiment.enrollment_token
  end

  def active_experiment_enrollments(at:, service_name:)
    valid_experiment_enrollments(at:).select do |experiment|
      experiment.state_at(at, service_name:) == :active
    end
  end

  def valid_experiment_enrollments(at:)
    raw_optins = session[:experiment_url_optins]
    return [] unless raw_optins

    tokens = raw_optins.is_a?(Array) ? raw_optins.map(&:to_s).reverse.uniq.reverse : []
    experiments = tokens.filter_map { |token| Rails.application.config.experiment_urls.find_by_enrollment_token(token) }
    unexpired = experiments.reject { |experiment| experiment.expired_at?(at) }
    session[:experiment_url_optins] = unexpired.map(&:enrollment_token)
    unexpired
  end
end
