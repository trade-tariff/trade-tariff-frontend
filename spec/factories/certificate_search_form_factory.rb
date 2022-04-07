FactoryBot.define do
  factory :certificate_search_form do
    type { 'N' }
    code { '002' }
    description { 'Certificate of conformity with the GB marketing standards for fresh fruit and vegetables' }
    page { 1 }

    initialize_with do
      params = ActionController::Parameters.new(
        type: type,
        code: code,
        description: description,
        page: page,
      )

      new(params)
    end
  end
end
