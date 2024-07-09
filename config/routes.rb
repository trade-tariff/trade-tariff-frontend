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
    "#{request.scheme}://#{ENV['HOST']}#{path}" # request.path starts with '/'
  }
  get '/v1/(*path)', to: redirect { |_params, request| "/api#{request.path}?#{request.query_string}" }
  get '/v2/(*path)', to: redirect { |_params, request| "/api#{request.path}?#{request.query_string}" }

  get '/api/:version/commodities/:id', constraints: { id: /\d{2}00000000/ }, to: redirect { |_params, request|
    path = request.path.gsub('commodities', 'chapters').gsub('00000000', '')
    query = URI(request.url).query

    url = "#{request.scheme}://#{ENV['HOST']}#{path}"

    query ? "#{url}?#{query}" : url
  }
  get '/api/:version/commodities/:id', constraints: { id: /\d{4}000000/ }, to: redirect { |_params, request|
    path = request.path.gsub('commodities', 'headings').gsub('000000', '')
    query = URI(request.url).query

    url = "#{request.scheme}://#{ENV['HOST']}#{path}"

    query ? "#{url}?#{query}" : url
  }
  get '/api/v1/quotas/search', to: redirect { |_params, request|
    path = request.path.gsub('v1', 'v2')
    query = URI(request.url).query

    url = "#{request.scheme}://#{ENV['HOST']}#{path}"

    query ? "#{url}?#{query}" : url
  }

  get 'healthcheck', to: 'healthcheck#check'
  get 'healthcheckz', to: 'healthcheck#checkz'

  get 'help', to: 'pages#help', as: 'help'
  get 'help/cn2021_cn2022', to: 'pages#cn2021_cn2022', as: 'cn2021_cn2022'
  get 'help/changes_999l', to: 'pages#changes_999l', as: 'help_changes_999l'
  get 'help/help_find_commodity', to: 'pages#help_find_commodity', as: 'help_find_commodity'
  get 'help/rules_of_origin/duty_drawback', to: 'pages#rules_of_origin_duty_drawback', as: 'rules_of_origin_duty_drawback'
  get 'help/rules_of_origin/proof_requirements/:id', to: 'pages#rules_of_origin_proof_requirements',
                                                     as: 'rules_of_origin_proof_requirements'
  get 'help/rules_of_origin/proof_verification/:id', to: 'pages#rules_of_origin_proof_verification',
                                                     as: 'rules_of_origin_proof_verification'
  get 'howto/:id', to: 'pages#howto', as: 'howto'

  get 'privacy', to: 'pages#privacy', as: 'privacy'
  get 'terms', to: 'pages#terms'

  resources :glossary, only: %i[index show], as: :glossary_terms, module: :pages

  get 'geographical_areas/:id', to: 'geographical_areas#show', as: :geographical_area

  resources :measure_types, only: [], module: 'measure_types' do
    resources :preference_codes, only: [:show]
  end

  resources :feedbacks, controller: 'feedback', only: %i[new create]

  get 'feedback', to: 'feedback#new'
  get 'feedback/thanks', to: 'feedback#thanks'

  get 'tools', to: 'pages#tools'

  resource :import_export_dates, only: %i[show update]
  resource :trading_partners, only: %i[show update]

  namespace :cookies do
    resource :policy, only: %i[show]
  end
  get 'cookies', to: redirect(path: '/cookies/policy')

  get '/news/collections/:collection_id(/:story_year)', to: 'news_items#index', as: :news_collection
  get '/news/years/:story_year', to: 'news_items#index', as: :news_year
  get '/news/stories/:id', to: 'news_items#show', as: :news_item
  resources :news_items, only: %i[index show], path: '/news'

  namespace :rules_of_origin, path: nil do
    with_options constraints: { commodity: /\d{10}/ } do
      get '/rules_of_origin/:commodity/:country', to: 'steps#index', as: :steps
      get '/rules_of_origin/:commodity/:country/:id', to: 'steps#show', as: :step
      patch '/rules_of_origin/:commodity/:country/:id', to: 'steps#update', as: nil
      get '/rules_of_origin/:commodity', to: 'product_specific_rules#index',
                                         as: :product_specific_rules
    end
    get '/rules_of_origin/proofs', to: 'proofs#index', as: :proofs
  end

  resolve('GreenLanes::CategoryAssessmentSearch') { [:category_assessments] }

  scope constraints: ->(_req) { TradeTariffFrontend::ServiceChooser.uk? } do
    namespace :green_lanes do
      resource :category_assessments, only: %i[create show]

      resource :check_moving_requirements, controller: 'moving_requirements', only: %i[update edit] do
        get 'start'
        get 'result'
        get 'cat_1_exemptions_questions', as: :cat_1_questions
        get 'cat_2_exemptions_questions', as: :cat_2_questions
      end
    end
  end

  match '/search', as: :perform_search, via: %i[get post], to: 'search#search'

  get '/search/toggle_beta_search', as: :toggle_beta_search, to: 'search#toggle_beta_search'

  scope constraints: ->(_req) { TradeTariffFrontend::ServiceChooser.uk? } do
    get 'exchange_rates(/:type)', to: 'exchange_rates#index', as: 'exchange_rates'

    get 'exchange_rates/view/:id', to: 'exchange_rates#show', as: 'exchange_rate_collection'
  end

  get 'search_suggestions', to: 'search#suggestions', as: :search_suggestions
  get 'quota_search', to: 'search#quota_search', as: :quota_search
  get 'simplified_procedure_value', to: 'simplified_procedural_values#index', as: :simplified_procedural_values
  get 'additional_code_search', to: 'additional_code_search#new', as: :additional_code_search
  post 'additional_code_search', to: 'additional_code_search#create', as: :perform_additional_code_search
  get 'certificate_search', to: 'certificate_search#new', as: :certificate_search
  post 'certificate_search', to: 'certificate_search#create', as: :perform_certificate_search
  get 'footnote_search', to: 'footnote_search#new', as: :footnote_search
  post 'footnote_search', to: 'footnote_search#create', as: :perform_footnote_search
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

  constraints(id: /\d{10}-\d{2}/) do
    resources :subheadings, only: %i[show]
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
  get '/pending_quota_balances/:commodity_id/:order_number',
      to: 'pending_quota_balances#show',
      as: :pending_quota_balance,
      defaults: { format: :json }

  constraints TradeTariffFrontend::ApiPubConstraints.new(TradeTariffFrontend.public_api_endpoints) do
    scope 'api' do
      get ':version/*path', to: TradeTariffFrontend::RequestForwarder.new(
        api_request_path_formatter: lambda { |path|
          path.gsub(/api\/v\d+\//, '')
        },
      ), constraints: { version: /v[1-2]{1}/ }

      post ':version/*path', to: TradeTariffFrontend::RequestForwarder.new(
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

  get '/', to: redirect(TradeTariffFrontend.production? ? 'https://www.gov.uk/trade-tariff' : '/find_commodity', status: 302)

  get '/robots.:format', to: 'pages#robots'
  match '/400', to: 'errors#bad_request', via: :all
  match '/404', to: 'errors#not_found', via: :all
  match '/405', to: 'errors#method_not_allowed', via: :all
  match '/406', to: 'errors#not_acceptable', via: :all
  match '/422', to: 'errors#unprocessable_entity', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '/501', to: 'errors#not_implemented', via: :all
  match '/503', to: 'errors#maintenance', via: :all
  match '*path', to: 'errors#not_found', via: :all
end
