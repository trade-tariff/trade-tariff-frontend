FactoryBot.define do
  factory :certificate_search_form do
    code { 'N002' }
    description { 'Certificate of conformity with the GB marketing standards for fresh fruit and vegetables' }

    initialize_with do
      params = ActionController::Parameters
        .new(code:, description:)
        .permit(:code, :description)

      new(params)
    end
  end
end
