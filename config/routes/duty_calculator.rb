scope path: '/duty-calculator/:commodity_code/' do
  get 'import-date', to: 'duty_calculator/steps/import_date#show'
  post 'import-date', to: 'duty_calculator/steps/import_date#create'
end

scope path: '/duty-calculator/' do
  get 'import-destination', to: 'duty_calculator/steps/import_destination#show'
  post 'import-destination', to: 'duty_calculator/steps/import_destination#create'

  get 'country-of-origin', to: 'duty_calculator/steps/country_of_origin#show'
  post 'country-of-origin', to: 'duty_calculator/steps/country_of_origin#create'

  get 'customs-value', to: 'duty_calculator/steps/customs_value#show'
  post 'customs-value', to: 'duty_calculator/steps/customs_value#create'

  get 'trader-scheme', to: 'duty_calculator/steps/trader_scheme#show'
  post 'trader-scheme', to: 'duty_calculator/steps/trader_scheme#create'

  get 'final-use', to: 'duty_calculator/steps/final_use#show'
  post 'final-use', to: 'duty_calculator/steps/final_use#create'

  get 'certificate-of-origin', to: 'duty_calculator/steps/certificate_of_origin#show'
  post 'certificate-of-origin', to: 'duty_calculator/steps/certificate_of_origin#create'

  get 'annual-turnover', to: 'duty_calculator/steps/annual_turnover#show'
  post 'annual-turnover', to: 'duty_calculator/steps/annual_turnover#create'

  get 'planned-processing', to: 'duty_calculator/steps/planned_processing#show'
  post 'planned-processing', to: 'duty_calculator/steps/planned_processing#create'

  get 'measure-amount', to: 'duty_calculator/steps/measure_amount#show'
  post 'measure-amount', to: 'duty_calculator/steps/measure_amount#create'

  get 'vat', to: 'duty_calculator/steps/vat#show'
  post 'vat', to: 'duty_calculator/steps/vat#create'

  get 'confirm', to: 'duty_calculator/steps/confirmation#show'

  get 'interstitial', to: 'duty_calculator/steps/interstitial#show'

  get 'duty', to: 'duty_calculator/steps/duty#show'

  get 'additional-codes/:measure_type_id', to: 'duty_calculator/steps/additional_codes#show', as: 'additional_codes'
  post 'additional-codes/:measure_type_id', to: 'duty_calculator/steps/additional_codes#create'

  get 'meursing-additional-codes', to: 'duty_calculator/steps/meursing_additional_codes#show', as: 'meursing_additional_codes'
  post 'meursing-additional-codes', to: 'duty_calculator/steps/meursing_additional_codes#create'

  get 'excise/:measure_type_id', to: 'duty_calculator/steps/excise#show', as: 'excise'
  post 'excise/:measure_type_id', to: 'duty_calculator/steps/excise#create'

  get 'document-codes/:measure_type_id', to: 'duty_calculator/steps/document_codes#show', as: 'document_codes'
  post 'document-codes/:measure_type_id', to: 'duty_calculator/steps/document_codes#create'

  get 'stopping', to: 'duty_calculator/steps/stopping#show', as: 'stopping'

  get 'prefill', to: 'duty_calculator/steps/prefill_user_session#show'
end
