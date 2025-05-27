module DutyCalculator
  # Helper for UK Internal Market Scheme
  module UkimsHelper
    CUT_OFF_DATE = Date.new(2023, 9, 30)

    def market_scheme_type
      if after_cut_off_date?
        'UK Internal Market Scheme'
      else
        'UK Trader Scheme'
      end
    end

    def trader_scheme_header
      if after_cut_off_date?
        'Are you authorised under the UK Internal Market Scheme'
      else
        'Were you authorised under the UK Trader Scheme (UKTS) or the UK Internal Market Scheme (UKIMS)'
      end
    end

    def trader_scheme_body
      if after_cut_off_date?
        "If you are moving goods into Northern Ireland which are for sale to, or final use by, end consumers located in the UK and you are authorised under the UK Internal Market Scheme, then you may declare your goods as being 'not at risk' where the requirements are met. A 'not at risk' good entering Northern Ireland from Great Britain will not be subject to duty."
      else
        "If you were moving goods into Northern Ireland which are for sale to, or final use by, end consumers located in the UK and you were authorised under the UK Trader Scheme or the UK Internal Market Scheme, then you may declare your goods as being 'not at risk' where the requirements are met. A 'not at risk' good entering Northern Ireland from Great Britain will not be subject to duty."
      end
    end

    def internal_market_scheme_note
      if after_cut_off_date?
        ''
      else
        <<NOTE
      <p>
      Please note that UK Internal Market scheme trades cannot benefit from expanded processing rules before 30 September 2023. Trades before this date will use the UK Trader Scheme rules on processing
      </p>
NOTE
      end
    end

    def trader_scheme_bullet_point_true
      if after_cut_off_date?
        'Yes, I am authorised under the UK Internal Market Scheme'
      else
        'Yes, I was authorised under the UK Trader Scheme or UK Internal Market Scheme at the time of the trade'
      end
    end

    def trader_scheme_bullet_point_no
      if after_cut_off_date?
        'No, I am not authorised under the UK Internal Market Scheme'
      else
        'No, I was not authorised under the UK Trader Scheme or UK Internal Market Scheme at the time of the trade'
      end
    end

    def ukims_annual_turnover
      if after_cut_off_date?
        '£2,000,000'
      else
        '£500,000'
      end
    end

    def explore_topic_title
      if after_cut_off_date?
        'Find out more about the Windsor Framework'
      else
        'Explore the topic'
      end
    end

    def commercial_processing_hint_text
      if after_cut_off_date?
        t('planned_processing.commercial_processing.hint_text_html.after_windsor_framework_html')
      else
        t('planned_processing.commercial_processing.hint_text_html.before_windsor_framework_html')
      end
    end

    private

    def after_cut_off_date?
      return false unless user_session.import_date

      user_session.import_date >= CUT_OFF_DATE
    end
  end
end
