require 'trade_tariff_frontend'
require 'routing_filter/service_path_prefix_handler'

Rails.application.routes.draw do
  filter :service_path_prefix_handler
  default_url_options(host: TradeTariffFrontend.host)

  namespace :meursing_lookup do
    resources :steps, only: %i[show update]
    resource :result, only: %i[show create]
  end

  namespace :feed, defaults: { format: 'atom' } do
    resources :news_items, only: %i[index]
  end

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

  namespace :cookies do
    resource :policy, only: %i[show]
  end
  get 'cookies', to: redirect(path: '/cookies/policy')

  get '/news/collections/:collection_id(/:story_year)', to: 'news_items#index', as: :news_collection
  get '/news/years/:story_year', to: 'news_items#index', as: :news_year
  get '/news/stories/:id', to: 'news_items#show', as: :news_item
  resources :news_items, only: %i[index show], path: '/news'

  get '/live_issues', to: 'live_issues#index'

  namespace :myott, path: 'subscriptions' do
    get '/', to: 'subscriptions#index'
    get 'start', to: 'subscriptions#start'
    get 'invalid', to: 'subscriptions#invalid'

    resource :stop_press, only: %i[show] do
      get 'check_your_answers'
      post 'subscribe'
      get 'confirmation'

      resource :preferences, only: %i[new create edit update]
    end

    resources :mycommodities, only: %i[index new create] do
      collection do
        get :active
        get :expired
        get :invalid
        get :confirmation
        get :download
      end
    end

    resources :commodity_changes, only: [] do
      collection do
        get :ending
        get :classification
      end
    end

    resources :grouped_measure_changes, only: %i[show]
    resources :grouped_measure_commodity_changes, only: %i[show]

    resources :unsubscribes, only: %i[show destroy], path: 'unsubscribe' do
      collection do
        get 'confirmation'
      end
    end
  end

  namespace :product_experience, path: '', as: 'product_experience' do
    scope path: 'enquiry_form', as: 'enquiry_form', controller: 'enquiry_form' do
      get '/', action: 'show'
      get 'check_your_answers'
      post 'submit', action: 'submit_form', as: 'submit_form'
      get 'confirmation'
      get ':field', action: 'form', as: 'field', constraints: {
        field: /full_name|company_name|occupation|email_address|category|query/,
      }
      post ':field', action: 'submit', constraints: {
        field: /full_name|company_name|occupation|email_address|category|query/,
      }
    end
  end

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

  get 'green_lanes' => 'green_lanes/results#show' # Old path. Now "check_spimm_eligibility".
  get '/check_spimm_eligibility(/:path)', to: redirect('/check_simplified_processes_eligibility', status: :moved_permanently)

  namespace :green_lanes, path: 'check_simplified_processes_eligibility' do
    get '/', to: 'starts#new', as: 'start'

    resource :category_assessments, only: %i[create show]

    get 'your_movement', to: 'eligibilities#new'
    resource :eligibility, only: %i[new create], path: 'your_movement'

    get :eligibility_result, to: 'eligibility_results#new', path: 'eligibility'

    get 'your_goods', to: 'moving_requirements#new'
    resource :moving_requirements, only: %i[new create], path: 'your_goods'

    get 'category_exemptions', to: 'applicable_exemptions#new'
    resource :applicable_exemptions, only: %i[new create], path: 'category_exemptions'

    resource :check_your_answers, only: %i[show]

    get 'result' => 'results#show'

    resources :results, param: :category, only: %i[create], path: 'result'

    get 'faq', to: 'faq#index'

    get 'get_feedback', to: 'faq#get_feedback'

    post 'send_feedback', to: 'faq#send_feedback', as: :send_feedback
  end

  match '/search', as: :perform_search, via: %i[get post], to: 'search#search'

  scope constraints: ->(_req) { TradeTariffFrontend::ServiceChooser.uk? } do
    get 'exchange_rates(/:type)', to: 'exchange_rates#index', as: 'exchange_rates'
    get 'exchange_rates/view/:id', to: 'exchange_rates#show', as: 'exchange_rate_collection'
    get 'exchange_rates/view/files/:id', to: 'exchange_rates#files', as: 'exchange_rate_file'
  end

  get 'search_suggestions', to: 'search#suggestions', as: :search_suggestions
  get 'internal_search_suggestions', to: 'search#interactive_suggestions', as: :interactive_search_suggestions
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

  # The following routes are how gov.uk links to the trade tariff
  get '/', to: redirect(TradeTariffFrontend.production? ? 'https://www.gov.uk/trade-tariff' : '/find_commodity', status: 302), as: :root
  get '/trade-tariff/sections', to: redirect('/find_commodity', status: 301)
  get '/trade-tariff/headings', to: redirect('/find_commodity', status: 301)
  get '/trade-tariff/headings/:heading_id', to: redirect('/headings/%{heading_id}', status: 301), constraints: { heading_id: /\d+/ }

  resources :basic_sessions, only: %i[new create] if TradeTariffFrontend.basic_session_authentication?

  draw('duty_calculator')

  post '/csp-violation-report', to: 'csp_reports#create'

  get '/robots.:format', to: 'pages#robots'
  match '/400', to: 'errors#bad_request', via: :all
  match '/404', to: 'errors#not_found', via: :all, as: :not_found
  match '/405', to: 'errors#method_not_allowed', via: :all
  match '/406', to: 'errors#not_acceptable', via: :all
  match '/422', to: 'errors#unprocessable_entity', via: :all
  match '/429', to: 'errors#too_many_requests', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '/501', to: 'errors#not_implemented', via: :all
  match '/503', to: 'errors#maintenance', via: :all
  match '*path', to: 'errors#not_found', via: :all
end
