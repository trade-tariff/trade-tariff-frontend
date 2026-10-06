RSpec.describe DutyCalculator::Steps::ImportDetails, :user_session do
  subject(:step) { described_class.new(attributes) }

  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }
  let(:attributes) do
    {
      'import_date(3i)' => '1',
      'import_date(2i)' => '9',
      'import_date(1i)' => '2026',
      'import_destination' => import_destination,
      'country_of_origin' => country_of_origin,
    }
  end
  let(:import_destination) { 'UK' }
  let(:country_of_origin) { 'AR' }

  describe '#valid?' do
    it { is_expected.to be_valid }

    context 'when the import destination is blank' do
      let(:import_destination) { '' }

      it 'adds the existing destination error' do
        step.valid?

        expect(step.errors.messages[:import_destination]).to eq(['Select a destination'])
      end
    end

    context 'when the country of origin is blank' do
      let(:country_of_origin) { '' }

      it 'adds the existing origin error' do
        step.valid?

        expect(step.errors.messages[:country_of_origin]).to eq(['Enter a valid origin for this import'])
      end
    end

    context 'when the date is impossible' do
      let(:attributes) { super().merge('import_date(3i)' => '31', 'import_date(2i)' => '2') }

      it 'adds the existing date error' do
        step.valid?

        expect(step.errors.messages[:import_date]).to eq(['Enter a valid date, no earlier than 1st January 2021'])
      end
    end

    context 'when the date is before 2021' do
      let(:attributes) { super().merge('import_date(1i)' => '2020') }

      it { is_expected.not_to be_valid }
    end

    context 'when the country is not on the list for the destination' do
      let(:import_destination) { 'XI' }
      let(:country_of_origin) { 'MC' }

      before do
        allow(DutyCalculator::Api::GeographicalArea).to receive(:list_countries).and_call_original
        allow(DutyCalculator::Api::GeographicalArea).to receive(:list_countries).with(:xi).and_return(
          [DutyCalculator::Api::GeographicalArea.new(geographical_area_id: 'GB', description: 'United Kingdom (excluding Northern Ireland)')],
        )
      end

      it 'adds the existing origin error' do
        step.valid?

        expect(step.errors.messages[:country_of_origin]).to eq(['Enter a valid origin for this import'])
      end
    end

    context 'when importing into Northern Ireland from Northern Ireland' do
      let(:import_destination) { 'XI' }
      let(:country_of_origin) { 'XI' }

      it { is_expected.not_to be_valid }
    end
  end

  describe '#save!' do
    before { step.save! }

    it { expect(user_session.import_date).to eq(Date.new(2026, 9, 1)) }
    it { expect(user_session.import_destination).to eq('UK') }
    it { expect(user_session.country_of_origin).to eq('AR') }
    it { expect(user_session.commodity_source).to eq('uk') }

    context 'when importing into Northern Ireland from GB' do
      let(:import_destination) { 'XI' }
      let(:country_of_origin) { 'GB' }

      it { expect(user_session.country_of_origin).to eq('GB') }
      it { expect(user_session.commodity_source).to eq('xi') }
    end

    context 'when importing into Northern Ireland from an EU member' do
      let(:import_destination) { 'XI' }
      let(:country_of_origin) { 'PL' }

      it { expect(user_session.country_of_origin).to eq('PL') }
      it { expect(user_session).to be_eu_to_ni_route }
    end

    context 'when importing into Northern Ireland from the rest of the world' do
      let(:import_destination) { 'XI' }
      let(:country_of_origin) { 'AR' }

      it { expect(user_session.country_of_origin).to eq('OTHER') }
      it { expect(user_session.other_country_of_origin).to eq('AR') }
    end
  end

  describe '#changed?' do
    let(:user_session) do
      build(
        :duty_calculator_user_session,
        :with_commodity_information,
        :with_vat,
        import_date: '2026-09-01',
        import_destination: 'UK',
        country_of_origin: 'AR',
      )
    end

    context 'when the answers are the same as before' do
      before { step.save! }

      it { is_expected.not_to be_changed }
      it { expect(user_session.vat).to be_present }
    end

    context 'when an answer is different' do
      let(:country_of_origin) { 'EG' }

      before { step.save! }

      it { is_expected.to be_changed }
      it { expect(user_session.vat).to be_nil }
      it { expect(user_session.vat_assumed).to be(false) }
    end
  end

  describe '#next_step_path' do
    before { step.save! }

    it { expect(step.next_step_path).to eq('/duty-calculator/customs-value') }

    context 'when importing into GB from Northern Ireland' do
      let(:country_of_origin) { 'XI' }

      it { expect(step.next_step_path).to eq('/duty-calculator/duty') }
    end
  end

  describe '#previous_step_path' do
    it { expect(step.previous_step_path).to eq('/commodities/0702000007') }
  end

  describe '.country_options' do
    it 'uses the UK list, with Northern Ireland, for GB' do
      expect(described_class.country_options('UK').map(&:id)).to include('XI', 'EG')
    end

    it 'uses the XI list for Northern Ireland' do
      expect(described_class.country_options('XI').map(&:id)).to include('GB', 'EG')
    end

    it 'does not offer Northern Ireland when importing into Northern Ireland' do
      expect(described_class.country_options('XI').map(&:id)).not_to include('XI')
    end

    it 'shows the country code after the name' do
      expect(described_class.country_options('UK').find { |option| option.id == 'XI' }.name).to eq('United Kingdom (Northern Ireland) (XI)')
    end

    it 'sorts by name' do
      names = described_class.country_options('XI').map(&:name)

      expect(names).to eq(names.sort)
    end
  end
end
