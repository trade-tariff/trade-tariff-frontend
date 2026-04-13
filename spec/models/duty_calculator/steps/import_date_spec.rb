RSpec.describe DutyCalculator::Steps::ImportDate, :step, :user_session do
  subject(:step) do
    build(
      :duty_calculator_import_date,
      user_session:,
      day:,
      month:,
      year:,
    )
  end

  let(:user_session) { build(:duty_calculator_user_session) }
  let(:session) { user_session.session }
  let(:day) { '12' }
  let(:month) { '12' }
  let(:year) { 1.year.from_now.year.to_s }

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it 'returns the correct list of steps' do
      expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(
        %w[
          import_destination
          country_of_origin
          trader_scheme
          final_use
          certificate_of_origin
          annual_turnover
          planned_processing
          document_code
          excise
          vat
        ],
      )
    end
  end

  describe '#validations' do
    context 'when import date is blank' do
      let(:day) { '' }
      let(:month) { '' }
      let(:year) { '' }

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error message' do
        step.valid?

        expect(step.errors.messages[:import_date]).to eq(['Enter a valid date, no earlier than 1st January 2021'])
      end
    end

    context 'when import date is incomplete' do
      let(:day) { '' }
      let(:month) { '12' }
      let(:year) { '' }

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error message' do
        step.valid?

        expect(step.errors.messages[:import_date]).to eq(['Enter a valid date, no earlier than 1st January 2021'])
      end
    end

    context 'when import date contains non numeric characters' do
      let(:day) { '12' }
      let(:month) { '12' }
      let(:year) { '@@' }

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error message' do
        step.valid?

        expect(step.errors.messages[:import_date]).to eq(['Enter a valid date, no earlier than 1st January 2021'])
      end
    end

    context 'when import date is in the past, earlier than 1st Jan 2021' do
      let(:day) { '31' }
      let(:month) { '12' }
      let(:year) { '2020' }

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error message' do
        step.valid?

        expect(step.errors.messages[:import_date]).to eq(['Enter a valid date, no earlier than 1st January 2021'])
      end
    end

    context 'when import date is in the past, but not earlier than 1st Jan 2021' do
      let(:day) { '1' }
      let(:month) { '1' }
      let(:year) { '2021' }

      it 'is a valid object' do
        expect(step).to be_valid
      end

      it 'has no validation errors' do
        step.valid?

        expect(step.errors.messages[:import_date]).to be_empty
      end
    end

    context 'when import date is invalid' do
      let(:day) { '12' }
      let(:month) { '34' }
      let(:year) { '3000' }

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error message' do
        step.valid?

        expect(step.errors.messages[:import_date]).to eq(['Enter a valid date, no earlier than 1st January 2021'])
      end
    end

    context 'when import date is valid and in future' do
      it 'is a valid object' do
        expect(step).to be_valid
      end

      it 'has no validation errors' do
        step.valid?

        expect(step.errors.messages[:import_date]).to be_empty
      end
    end
  end

  describe '#import_date' do
    context 'when super returns a Date (form params present)' do
      it 'returns the Date unchanged' do
        expect(step.import_date).to be_a(Date)
      end
    end

    context 'when super is nil and the session holds a String date' do
      subject(:step) do
        build(:duty_calculator_import_date, user_session:, day: '', month: '', year: '')
      end

      before do
        allow(user_session).to receive(:import_date).and_return('2023-06-19')
      end

      it 'returns a Date' do
        expect(step.import_date).to be_a(Date)
      end

      it 'returns the correct date' do
        expect(step.import_date).to eq(Date.new(2023, 6, 19))
      end
    end

    context 'when both super and session are nil' do
      subject(:step) do
        build(:duty_calculator_import_date, user_session:, day: '', month: '', year: '')
      end

      before do
        allow(user_session).to receive(:import_date).and_return(nil)
      end

      it 'returns a Date' do
        expect(step.import_date).to be_a(Date)
      end

      it 'returns today' do
        expect(step.import_date).to eq(Time.zone.today)
      end
    end

    context 'when the session holds an unparseable string' do
      subject(:step) do
        build(:duty_calculator_import_date, user_session:, day: '', month: '', year: '')
      end

      before do
        allow(user_session).to receive(:import_date).and_return('not-a-date')
      end

      it 'returns a Date' do
        expect(step.import_date).to be_a(Date)
      end

      it 'falls back to today' do
        expect(step.import_date).to eq(Time.zone.today)
      end
    end
  end

  describe '#save!' do
    let(:expected_date) { Date.parse("#{1.year.from_now.year}-12-12") }

    it 'saves the import_date to the session' do
      expect { step.save! }.to change(user_session, :import_date).from(nil).to(expected_date)
    end
  end

  describe '#next_step_path' do
    it 'returns import_destination_path' do
      expect(
        step.next_step_path,
      ).to eq(
        import_destination_path,
      )
    end
  end
end
