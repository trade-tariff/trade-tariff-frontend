FactoryBot.define do
  factory :feedback do
    message { 'Hello world' }
    referrer { 'https://example.com' }
    page_useful { 'yes' }
    query { 'leather handbags' }
    request_id { 'test-request-id' }
    date { '2026-06-05' }

    trait :with_authenticity_token do
      authenticity_token do
        'YZDyyHGMqRyXH1ALc0-helPFpCAcUgdyGlErrPgbtvwYxK4ftq6t2xNcfgoknWADYZY9zxncvyiZhvFPTS-irw'
      end
    end

    trait :with_invalid_choice do
      page_useful { 'invalid' }
    end

    trait :with_message_containing_link_text do
      message { 'google.com' }
    end

    trait :with_message_containing_integers_only do
      message { '1234567890' }
    end
  end
end
