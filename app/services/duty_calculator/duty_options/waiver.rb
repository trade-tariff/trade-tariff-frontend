module DutyCalculator
  module DutyOptions
    class Waiver < DutyOptions::Base
      PRIORITY = 10
      CATEGORY = :waiver

      def call
        DutyOptionResult.new(
          type: 'waiver',
          footnote: I18n.t('default_option_footnotes.waiver').html_safe,
          warning_text: nil,
          values: nil,
          category: CATEGORY,
          priority: PRIORITY,
        )
      end
    end
  end
end
