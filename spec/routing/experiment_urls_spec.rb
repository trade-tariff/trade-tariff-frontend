require 'spec_helper'

RSpec.describe 'Experiment URLs', type: :routing do
  let(:experiment) { Rails.application.config.experiment_urls.fetch(:trusted_trader_guided_search) }

  it 'loads immutable exact routes after concrete application routes', :aggregate_failures do
    expect(Rails.application.config.experiment_urls).to be_frozen
    expect(get: experiment.path).to route_to(controller: 'experiment_urls', action: 'show',
                                             experiment_key: 'trusted_trader_guided_search')
    expect(get: '/find_commodity').to route_to(controller: 'find_commodities', action: 'show')
    routes = Rails.application.routes.routes.to_a
    concrete = routes.index { |route| route.defaults[:controller] == 'find_commodities' }
    experiment_route = routes.index { |route| route.defaults[:controller] == 'experiment_urls' }
    expect(experiment_route).to be > concrete
    ["#{experiment.path}/extra", "#{experiment.path}.json"].each do |path|
      expect(get: path).not_to route_to(controller: 'experiment_urls', action: 'show',
                                        experiment_key: 'trusted_trader_guided_search')
    end
  end
end
