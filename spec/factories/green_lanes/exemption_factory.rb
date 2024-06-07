FactoryBot.define do
  factory :green_lanes_exemption, class: 'GreenLanes::Exemption' do
    sequence(:code)        { |n| sprintf 'E%03d', n }
    sequence(:description) { |n| "Green Lanes Exemption #{n}" }
    formatted_description  { description }
  end
end
