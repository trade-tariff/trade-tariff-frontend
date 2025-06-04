RSpec.describe DutyCalculator::UkimsHelper, :user_session do
  before do
    allow(DutyCalculator::UserSession).to receive(:get).and_return(user_session)
    allow(helper).to receive(:user_session).and_return(user_session)
  end

  let(:import_date) { Date.new(2023, 9, 30).strftime('%Y-%m-%d') }

  let(:user_session) do
    build(
      :duty_calculator_user_session,
      import_date:,
    )
  end

  describe '#market_scheme_type' do
    context 'when the import date is after the cut off' do
      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.market_scheme_type).to eq('UK Internal Market Scheme')
      end
    end

    context 'when the import date is before the cut off' do
      let(:import_date) { Date.new(2023, 9, 29).strftime('%Y-%m-%d') }

      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.market_scheme_type).to eq('UK Trader Scheme')
      end
    end
  end

  describe '#trader_scheme_header' do
    context 'when the import date is after the cut off' do
      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.trader_scheme_header).to eq('Are you authorised under the UK Internal Market Scheme')
      end
    end

    context 'when the import date is before the cut off' do
      let(:import_date) { Date.new(2023, 9, 29).strftime('%Y-%m-%d') }

      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.trader_scheme_header).to eq('Were you authorised under the UK Trader Scheme (UKTS) or the UK Internal Market Scheme (UKIMS)')
      end
    end
  end

  describe '#trader_scheme_body' do
    context 'when the import date is after the cut off' do
      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.trader_scheme_body).to include('or final use by, end consumers located in the UK and you are authorised under the UK Internal Market Scheme')
      end
    end

    context 'when the import date is before the cut off' do
      let(:import_date) { Date.new(2023, 9, 29).strftime('%Y-%m-%d') }

      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.trader_scheme_body).to include('or final use by, end consumers located in the UK and you were authorised under the UK Trader Scheme or the UK Internal Market Scheme')
      end
    end
  end

  describe '#internal_market_scheme_note' do
    context 'when the import date is after the cut off' do
      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.internal_market_scheme_note).to eq('')
      end
    end

    context 'when the import date is before the cut off' do
      let(:import_date) { Date.new(2023, 9, 29).strftime('%Y-%m-%d') }

      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.internal_market_scheme_note).to include('cannot benefit from expanded processing rules before 30 September 2023')
      end
    end
  end

  describe '#trader_scheme_bullet_point_true' do
    context 'when the import date is after the cut off' do
      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.trader_scheme_bullet_point_true).to eq('Yes, I am authorised under the UK Internal Market Scheme')
      end
    end

    context 'when the import date is before the cut off' do
      let(:import_date) { Date.new(2023, 9, 29).strftime('%Y-%m-%d') }

      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.trader_scheme_bullet_point_true).to eq('Yes, I was authorised under the UK Trader Scheme or UK Internal Market Scheme at the time of the trade')
      end
    end
  end

  describe '#trader_scheme_bullet_point_no' do
    context 'when the import date is after the cut off' do
      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.trader_scheme_bullet_point_no).to eq('No, I am not authorised under the UK Internal Market Scheme')
      end
    end

    context 'when the import date is before the cut off' do
      let(:import_date) { Date.new(2023, 9, 29).strftime('%Y-%m-%d') }

      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.trader_scheme_bullet_point_no).to eq('No, I was not authorised under the UK Trader Scheme or UK Internal Market Scheme at the time of the trade')
      end
    end
  end

  describe '#ukims_annual_turnover' do
    context 'when the import date is after the cut off' do
      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.ukims_annual_turnover).to eq('£2,000,000')
      end
    end

    context 'when the import date is before the cut off' do
      let(:import_date) { Date.new(2023, 9, 29).strftime('%Y-%m-%d') }

      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.ukims_annual_turnover).to eq('£500,000')
      end
    end
  end

  describe '#explore_topic_title' do
    context 'when the import date is after the cut off' do
      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.explore_topic_title).to eq('Find out more about the Windsor Framework')
      end
    end

    context 'when the import date is before the cut off' do
      let(:import_date) { Date.new(2023, 9, 29).strftime('%Y-%m-%d') }

      it 'returns the corect string when the import_date is after cut off date' do
        expect(helper.explore_topic_title).to eq('Explore the topic')
      end
    end
  end
end
