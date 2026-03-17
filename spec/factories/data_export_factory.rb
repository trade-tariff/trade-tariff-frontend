FactoryBot.define do
  factory :data_export, class: 'DataExport' do
    resource_id { '5' }
    status { 'queued' }

    trait :processing do
      status { 'processing' }
    end

    trait :completed do
      status { 'completed' }
    end
  end
end
