FactoryBot.define do
  factory :feedback do
    message { 'Hello world' }
    referrer { 'https://example.com' }
    page_useful { 'yes' }

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
  end
end
