FactoryBot.define do
  factory :search do
    transient do
      search_date {}
    end

    q { 'foo' }

    trait :with_search_date do
      transient do
        search_date { Time.zone.today }
      end

      day { search_date.day.to_s.rjust(2, '0') }
      month { search_date.month.to_s.rjust(2, '0') }
      year { search_date.year.to_s.rjust(2, '0') }
    end

    trait :with_country do
      country { 'IT' }
    end
  end
end
