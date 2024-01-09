FactoryBot.define do
  factory :feedback do
    message { 'Hello world' }
    referrer { 'https://example.com' }

    trait :with_authenticity_token do
      authenticity_token do
        'YZDyyHGMqRyXH1ALc0-helPFpCAcUgdyGlErrPgbtvwYxK4ftq6t2xNcfgoknWADYZY9zxncvyiZhvFPTS-irw'
      end
    end
  end
end
