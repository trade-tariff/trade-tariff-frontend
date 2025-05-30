FactoryBot.define do
  factory :duty_calculator_country_of_origin, class: 'DutyCalculator::Steps::CountryOfOrigin' do
    transient do
      user_session { build(:duty_calculator_user_session) }
    end
    country_of_origin { '' }
    zero_mfn_duty { '' }
    trade_defence { '' }

    initialize_with do
      parameters = ActionController::Parameters.new(country_of_origin:).permit(:country_of_origin)
      opts = {}
      opts[:zero_mfn_duty] = zero_mfn_duty unless zero_mfn_duty.nil?
      opts[:trade_defence] = trade_defence unless trade_defence.nil?
      Thread.current[:user_session] ||= user_session

      new(parameters, opts)
    end
  end
end
