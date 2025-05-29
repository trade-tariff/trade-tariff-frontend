RSpec.describe DutyCalculator::Api::Definition do
  it_behaves_like 'a resource that has attributes',
                  id: '20087',
                  initial_volume: '1366000.0',
                  validity_start_date: '2021-01-01T00:00:00.000Z',
                  validity_end_date: '2021-12-31T00:00:00.000Z',
                  status: 'Open',
                  description: nil,
                  balance: '1366000.0',
                  measurement_unit: 'Kilogram (kg)',
                  monetary_unit: nil,
                  measurement_unit_qualifier: nil,
                  last_allocation_date: nil,
                  suspension_period_start_date: nil,
                  suspension_period_end_date: nil,
                  blocking_period_start_date: nil,
                  blocking_period_end_date: nil
end
