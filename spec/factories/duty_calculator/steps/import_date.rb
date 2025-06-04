FactoryBot.define do
  factory :duty_calculator_import_date, class: 'DutyCalculator::Steps::ImportDate', parent: :duty_calculator_step do
    transient do
      possible_attributes do
        {
          day: 'import_date(3i)',
          month: 'import_date(2i)',
          year: 'import_date(1i)',
        }
      end

      day { '' }
      month { '' }
      year { '' }
    end
  end
end
