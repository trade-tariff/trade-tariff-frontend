FactoryBot.define do
  factory :tariff_update do
    update_type { 'TariffSynchronizer::TaricUpdate' }
    state { 'A' }
    created_at { Time.zone.now.iso8601 }
    updated_at { Time.zone.now.iso8601 }
    applied_at { Time.zone.now.iso8601 }
    filename { 'filename.txt' }
  end
end
