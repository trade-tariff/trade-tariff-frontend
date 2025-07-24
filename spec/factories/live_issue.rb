FactoryBot.define do
  factory :live_issue do
    commodities do
      %w[
        2106909815
        2106909816
      ]
    end

    date_discovered { '2025-07-08' }
    date_resolved { nil }
    description { "# Kramdown\n\n- Bullet point 1\n- Bullet point 2" }
    resource_id { '1' }
    resource_type { 'live_issue' }
    status { 'Active' }
    suggested_action { 'The Third Country duty rate or, with relevant proof, the CPTPP duty rate can be claimed. The Japan duty rate can only be processed once the DBT update has occurred.' }
    title { 'Missing Japan Preference' }
    updated_at { '2025-07-15T12:26:23.955Z' }
  end
end
