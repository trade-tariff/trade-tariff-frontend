class ExperimentUrlsController < ApplicationController
  skip_before_action :set_current_flagsmith_identity, :set_path_info, :set_search, :bots_no_index_if_historical

  def show
    experiment = Rails.application.config.experiment_urls.fetch(request.path_parameters[:experiment_key])
    response.headers['Cache-Control'] = 'no-store'
    now = Time.current
    redirect_path = "#{current_service_path_prefix}#{experiment.redirect_path}"

    if experiment.state_at(now, service_name: TradeTariffFrontend::ServiceChooser.service_name) == :active
      enroll_in_experiment(experiment, at: now)
      redirect_to "#{redirect_path}?experiment=#{experiment.instrumentation_label}"
    else
      redirect_to redirect_path
    end
  end

  private

  def current_service_path_prefix
    TradeTariffFrontend::ServiceChooser.xi? ? '/xi' : ''
  end
end
