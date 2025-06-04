FactoryBot.define do
  factory :duty_calculator_certificate_of_origin, class: 'DutyCalculator::Steps::CertificateOfOrigin', parent: :duty_calculator_step do
    transient { possible_attributes { { certificate_of_origin: 'certificate_of_origin' } } }

    certificate_of_origin { '' }
  end
end
