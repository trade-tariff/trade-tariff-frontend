FactoryBot.define do
  factory :legal_act do
    published_date { Time.zone.today.iso8601 }
    officialjournal_number {}
    officialjournal_page {}
    validity_start_date {}
    validity_end_date {}

    regulation_code { 'S.I. 2020/1432' }
    regulation_url { 'https://www.legislation.gov.uk/uksi/2020/1432' }
    description { 'The Customs Tariff (Preferential Trade Arrangements) (EU Exit) (Amendment) Regulations 2021' }
  end
end
