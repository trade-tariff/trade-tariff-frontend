require 'spec_helper'

RSpec.describe 'Experiment URLs', type: :routing do
  it 'loads immutable exact routes after concrete application routes', :aggregate_failures do
    expect(Rails.application.config.experiment_urls).to be_frozen
    expect(get: '/trusted-trader-guided-search').to route_to(controller: 'experiment_urls', action: 'show',
                                                             experiment_key: 'trusted_trader_guided_search')
    expect(get: '/find_commodity').to route_to(controller: 'find_commodities', action: 'show')
    routes = Rails.application.routes.routes.to_a
    concrete = routes.index { |route| route.defaults[:controller] == 'find_commodities' }
    experiment = routes.index { |route| route.defaults[:controller] == 'experiment_urls' }
    expect(experiment).to be > concrete
    %w[/trusted-trader-guided-search/extra /trusted-trader-guided-search.json].each do |path|
      expect(get: path).not_to route_to(controller: 'experiment_urls', action: 'show',
                                        experiment_key: 'trusted_trader_guided_search')
    end
  end
end
