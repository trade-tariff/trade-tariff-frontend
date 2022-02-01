require 'trade_tariff_frontend'
require 'trade_tariff_frontend/api_constraints'
require 'trade_tariff_frontend/request_forwarder'
require 'routing_filter/service_path_prefix_handler'

Rails.application.routes.draw do
  filter :service_path_prefix_handler
  default_url_options(host: TradeTariffFrontend.host)

  namespace :meursing_lookup do
    resources :steps, only: %i[show update]
    resources :results, only: %i[show create]
  end

  namespace :feed, defaults: { format: 'atom' } do
    resources :news_items, only: %i[index]
  end

  get '/trade-tariff/*path', to: redirect('/%{path}', status: 301)
  get '/api/(*path)', constraints: { path: /[^v\d+].*/ }, to: redirect { |_params, request|
    path = request.path.gsub('/api/', '/api/v2/')
    "https://#{ENV['HOST']}#{path}" # request.path starts with '/'
  }
  get '/v1/(*path)', to: redirect { |_params, request| "/api#{request.path}?#{request.query_string}" }
  get '/v2/(*path)', to: redirect { |_params, request| "/api#{request.path}?#{request.query_string}" }

  get '/api/:version/commodities/:id', constraints: { id: /\d{2}00000000/ }, to: redirect { |_params, request|
    path = request.path.gsub('commodities', 'chapters').gsub('00000000', '')
    query = URI(request.url).query

    url = "https://#{ENV['HOST']}#{path}"

    query ? "#{url}?#{query}" : url
  }
  get '/api/:version/commodities/:id', constraints: { id: /\d{4}000000/ }, to: redirect { |_params, request|
    path = request.path.gsub('commodities', 'headings').gsub('000000', '')
    query = URI(request.url).query

    url = "https://#{ENV['HOST']}#{path}"

    query ? "#{url}?#{query}" : url
  }
  get '/api/v1/quotas/search', to: redirect { |_params, request|
    path = request.path.gsub('v1', 'v2')
    query = URI(request.url).query

    url = "https://#{ENV['HOST']}#{path}"

    query ? "#{url}?#{query}" : url
  }

  get '/', to: redirect(TradeTariffFrontend.production? ? 'https://www.gov.uk/trade-tariff' : '/find_commodity', status: 302)
  get 'healthcheck', to: 'healthcheck#check'
  get 'opensearch', to: 'pages#opensearch', constraints: { format: :xml }
  get 'terms', to: 'pages#terms'
  get 'privacy', to: 'pages#privacy', as: 'privacy'
  get 'help', to: 'pages#help', as: 'help'
  get 'geographical_areas', to: 'geographical_areas#index', as: :geographical_areas
  get 'geographical_areas/:id', to: 'geographical_areas#show', as: :geographical_area
  get 'feedback', to: 'feedback#new'
  post 'feedback', to: 'feedback#create'
  get 'feedback/thanks', to: 'feedback#thanks'
  get 'tools', to: 'pages#tools'

  resource :import_export_dates, only: %i[show update]
  resource :trading_partners, only: %i[show update]

  namespace :cookies do
    resource :policy, only: %i[show create update]
    resource :hide_confirmation, only: %i[create]
  end
  resolve('Cookies::Policy') { %i[cookies policy] }
  get 'cookies', to: redirect(path: '/cookies/policy')

  resources :news_items, only: %i[index show], path: '/news'

  match '/search', to: 'search#search', as: :perform_search, via: %i[get post]
  get 'search_suggestions', to: 'search#suggestions', as: :search_suggestions
  get 'quota_search', to: 'search#quota_search', as: :quota_search
  get 'additional_code_search', to: 'search#additional_code_search', as: :additional_code_search
  get 'certificate_search', to: 'search#certificate_search', as: :certificate_search
  get 'footnote_search', to: 'search#footnote_search', as: :footnote_search
  get 'chemical_search', to: 'search#chemical_search', as: :chemical_search
  match 'a-z-index/:letter',
        to: 'search_references#show',
        via: :get,
        as: :a_z_index,
        constraints: { letter: /[a-z]{1}/i }

  constraints TradeTariffFrontend::ApiConstraints.new(
    TradeTariffFrontend.accessible_api_endpoints,
  ) do
    match ':endpoint/(*path)',
          via: :get,
          to: TradeTariffFrontend::RequestForwarder.new(
            api_request_path_formatter: lambda { |path|
              path.gsub("#{APP_SLUG}/", '')
            },
          )
  end

  constraints(id: /\d{1,2}/) do
    resources :sections, only: %i[index show]

    resources :browse_sections, path: '/browse', only: %i[index]
  end

  constraints(id: /\d{2}/) do
    resources :chapters, only: %i[show] do
      resources :changes,
                only: [:index],
                defaults: { format: :atom },
                module: 'chapters'
    end
  end

  constraints(id: /\d{4}/) do
    resources :headings, only: %i[show] do
      resources :changes,
                only: [:index],
                defaults: { format: :atom },
                module: 'headings'
    end
  end

  constraints(id: /\d{10}/) do
    resources :commodities, only: %i[show] do
      resources :changes,
                only: [:index],
                defaults: { format: :atom },
                module: 'commodities'
    end
  end
  get '/find_commodity', to: 'find_commodities#show'

  constraints TradeTariffFrontend::ApiPubConstraints.new(TradeTariffFrontend.public_api_endpoints) do
    scope 'api' do
      get ':version/*path', to: TradeTariffFrontend::RequestForwarder.new(
        api_request_path_formatter: lambda { |path|
          path.gsub(/api\/v\d+\//, '')
        },
      ), constraints: { version: /v[1-2]{1}/ }

      get 'v2/goods_nomenclatures/*path', to: TradeTariffFrontend::RequestForwarder.new(
        api_request_path_formatter: lambda { |path|
          path.gsub(/api\/v2\//, '')
        },
      )
    end
  end

  root to: redirect(TradeTariffFrontend.production? ? 'https://www.gov.uk/trade-tariff' : '/sections', status: 302)

  get '/robots.:format', to: 'pages#robots'
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '/503', to: 'errors#maintenance', via: :all
  match '*path', to: 'errors#not_found', via: :all
end
