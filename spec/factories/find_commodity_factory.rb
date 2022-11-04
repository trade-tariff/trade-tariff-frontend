FactoryBot.define do
  factory :find_commodity do
    q     { 'test search' }
    day   { Time.zone.today.day }
    month { Time.zone.today.month }
    year  { Time.zone.today.year }
  end
end
