RSpec.describe DutyCalculator::UserSession do
  subject(:user_session) { build(:duty_calculator_user_session, commodity_source: nil) }

  let(:session) { user_session.session }

  it_behaves_like 'a user session attribute', :commodity_code, '0702000007'
  it_behaves_like 'a user session attribute', :commodity_source, 'uk'
  it_behaves_like 'a user session attribute', :referred_service, 'uk'
  it_behaves_like 'a user session attribute', :trade_defence, false
  it_behaves_like 'a user session attribute', :zero_mfn_duty, false
  it_behaves_like 'a user session attribute', :redirect_to, 'http://localhost/flibble'

  it_behaves_like 'a user session attribute', :import_destination, 'XI'
  it_behaves_like 'a user session attribute', :country_of_origin, 'AR'
  it_behaves_like 'a user session attribute', :other_country_of_origin, 'AR'
  it_behaves_like 'a user session attribute', :trader_scheme, 'yes'
  it_behaves_like 'a user session attribute', :final_use, 'yes'
  it_behaves_like 'a user session attribute', :certificate_of_origin, 'yes'
  it_behaves_like 'a user session attribute', :planned_processing, 'commercial_processing'
  it_behaves_like 'a user session attribute', :vat, 'VATZ'
  it_behaves_like 'a user session attribute', :meursing_additional_code, '000'

  it_behaves_like 'a user session dual route attribute', :document_code, { '142' => 'N851', '353' => 'Y929' }
  it_behaves_like 'a user session dual route attribute', :additional_code, { '142' => '2340', '353' => '2601' }

  describe '#import_date' do
    subject(:user_session) { build(:duty_calculator_user_session) }

    it 'returns nil if the key is not on the session' do
      expect(user_session.import_date).to be_nil
    end

    context 'when the key is present on the session' do
      subject(:user_session) { build(:duty_calculator_user_session, import_date: '2025-01-01') }

      let(:expected_date) { Date.parse('2025-01-01') }

      it 'returns the value from the session' do
        expect(user_session.import_date).to eq(expected_date)
      end
    end
  end

  describe '#import_date=' do
    let(:expected_date) { '2025-01-01' }

    it 'sets the key on the session' do
      user_session.import_date = '2025-01-01'

      expect(session['answers'][DutyCalculator::Steps::ImportDate.id]).to eq(expected_date)
    end
  end

  describe '#insurance_cost' do
    subject(:user_session) { build(:duty_calculator_user_session, customs_value: { 'insurance_cost' => '340' }) }

    it 'returns the correct value from the session' do
      expect(user_session.insurance_cost).to eq('340')
    end
  end

  describe '#shipping_cost' do
    subject(:user_session) { build(:duty_calculator_user_session, customs_value: { 'shipping_cost' => '1_200' }) }

    it 'returns the correct value from the session' do
      expect(user_session.shipping_cost).to eq('1_200')
    end
  end

  describe '#monetary_value' do
    subject(:user_session) { build(:duty_calculator_user_session, customs_value: { 'monetary_value' => '12000' }) }

    it 'returns the correct value from the session' do
      expect(user_session.monetary_value).to eq('12000')
    end
  end

  describe '#customs_value=' do
    let(:value) do
      {
        'monetary_value' => 12_000,
        'shipping_cost' => 1_200,
        'insurance_cost' => 340,
      }
    end

    it 'stores the hash on the session' do
      user_session.customs_value = value

      expect(session['answers'][DutyCalculator::Steps::CustomsValue.id]).to eq(value)
    end
  end

  describe '#measure_amount' do
    subject(:user_session) { build(:duty_calculator_user_session, measure_amount: { foo: :bar }) }

    it 'returns the correct value from the session' do
      expect(user_session.measure_amount).to eq(foo: :bar)
    end
  end

  describe '#measure_amount=' do
    let(:value) { {} }

    it 'stores the hash on the session' do
      user_session.measure_amount = value

      expect(session['answers'][DutyCalculator::Steps::MeasureAmount.id]).to eq(value)
    end
  end

  describe '#additional_code_measure_type_ids' do
    subject(:user_session) do
      build(
        :duty_calculator_user_session,
        :with_additional_codes,
        :with_commodity_information,
      )
    end

    it 'returns the measure type ids from the session' do
      expect(user_session.additional_code_measure_type_ids).to eq(%w[105 103])
    end

    context 'when on the deltas applicable route' do
      subject(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_additional_codes,
          :with_commodity_information,
          :deltas_applicable,
        )
      end

      it 'accumulates measure type ids from both sources' do
        expect(user_session.additional_code_measure_type_ids).to eq(%w[105 103 142])
      end
    end
  end

  describe '#document_code_measure_type_ids' do
    subject(:user_session) do
      build(
        :duty_calculator_user_session,
        :with_document_codes,
        :with_commodity_information,
      )
    end

    it 'returns the measure type ids from the session' do
      expect(user_session.document_code_measure_type_ids).to eq(%w[103 105])
    end

    context 'when on the deltas applicable route' do
      subject(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_document_codes,
          :with_commodity_information,
          :deltas_applicable,
        )
      end

      it 'accumulates measure type ids from both sources' do
        expect(user_session.document_code_measure_type_ids).to eq(%w[103 105 142 353])
      end
    end
  end

  describe '#excise_additional_code' do
    subject(:user_session) do
      build(
        :duty_calculator_user_session,
        :with_commodity_information,
        :with_excise_additional_codes,
      )
    end

    it 'returns the correct value from the session' do
      expect(user_session.excise_additional_code).to eq('306' => '444', 'DBC' => '369')
    end
  end

  describe '#excise_additional_code=' do
    let(:value) { { '306' => 'X411' } }
    let(:expected_value) { { '306' => 'X411' } }
    let(:new_value) { { 'DAC' => 'X111' } }

    let(:merged_session) do
      {
        '306' => 'X411',
        'DAC' => 'X111',
      }
    end

    before do
      user_session.excise_additional_code = value
    end

    it 'stores the hash on the session' do
      expect(session['answers']['excise']).to eq(expected_value)
    end

    it 'merges new additional codes to the existing ones' do
      user_session.excise_additional_code = new_value

      expect(session['answers']['excise']).to eq(merged_session)
    end
  end

  describe '#excise_measure_type_ids' do
    subject(:user_session) do
      build(
        :duty_calculator_user_session,
        :with_excise_additional_codes,
        :with_commodity_information,
      )
    end

    it 'returns the measure type ids from the session' do
      expect(user_session.excise_measure_type_ids).to eq(%w[306 DBC])
    end
  end

  describe '#ni_to_gb_route?' do
    context 'when import country is GB and origin country is NI' do
      subject(:user_session) { build(:duty_calculator_user_session, import_destination: 'UK', country_of_origin: 'XI') }

      it 'returns true' do
        expect(user_session.ni_to_gb_route?).to be true
      end
    end

    it 'returns false otherwise' do
      expect(user_session.ni_to_gb_route?).to be false
    end
  end

  describe '#eu_to_ni_route?' do
    context 'when import country is NI and origin country is a EU Member' do
      subject(:user_session) { build(:duty_calculator_user_session, import_destination: 'XI', country_of_origin: 'RO') }

      it 'returns true' do
        expect(user_session.eu_to_ni_route?).to be true
      end
    end

    it 'returns false otherwise' do
      expect(user_session.eu_to_ni_route?).to be false
    end
  end

  describe '#gb_to_ni_route?' do
    context 'when import country is XI and origin country is GB' do
      subject(:user_session) { build(:duty_calculator_user_session, import_destination: 'XI', country_of_origin: 'GB') }

      it 'returns true' do
        expect(user_session.gb_to_ni_route?).to be true
      end
    end

    it 'returns false otherwise' do
      expect(user_session.gb_to_ni_route?).to be false
    end
  end

  describe '#row_to_gb_route?' do
    context 'when import country is UK and origin country is anything but XI' do
      subject(:user_session) { build(:duty_calculator_user_session, import_destination: 'UK', country_of_origin: 'RO') }

      it 'returns true' do
        expect(user_session.row_to_gb_route?).to be true
      end
    end

    it 'returns false otherwise' do
      expect(user_session.row_to_gb_route?).to be false
    end
  end

  describe '#row_to_ni_route?' do
    context 'when import country is XI and origin country is anything but GB or any EU member' do
      subject(:user_session) do
        build(
          :duty_calculator_user_session,
          import_destination: 'XI',
          country_of_origin: 'OTHER',
          other_country_of_origin: 'AR',
        )
      end

      it 'returns true' do
        expect(user_session.row_to_ni_route?).to be true
      end
    end

    it 'returns false otherwise' do
      expect(user_session.row_to_ni_route?).to be false
    end
  end

  describe '#acceptable_processing?' do
    context 'when the planned_processing answer is `commercial_purposes`' do
      subject(:user_session) { build(:duty_calculator_user_session, planned_processing: 'commercial_purposes') }

      it { is_expected.not_to be_acceptable_processing }
    end

    context 'when the planned_processing answer is not `commercial_purposes`' do
      subject(:user_session) { build(:duty_calculator_user_session, planned_processing: 'foo') }

      it { is_expected.to be_acceptable_processing }
    end
  end

  describe '#unacceptable_processing?' do
    context 'when the planned_processing answer is `commercial_purposes`' do
      subject(:user_session) { build(:duty_calculator_user_session, planned_processing: 'commercial_purposes') }

      it { is_expected.to be_unacceptable_processing }
    end

    context 'when the planned_processing answer is not `commercial_purposes`' do
      subject(:user_session) { build(:duty_calculator_user_session, planned_processing: 'foo') }

      it { is_expected.not_to be_unacceptable_processing }
    end
  end

  describe '#deltas_applicable?' do
    context 'when on a deltas applicable route with unnacceptable commercial purposes and a small turnover' do
      subject(:user_session) { build(:duty_calculator_user_session, :deltas_applicable, :with_small_turnover, planned_processing: 'commercial_purposes') }

      it { is_expected.to be_deltas_applicable }
    end

    context 'when on a deltas applicable route with acceptable commercial processing and a high turnover' do
      subject(:user_session) { build(:duty_calculator_user_session, :deltas_applicable, :with_large_turnover, planned_processing: 'without_any_processing') }

      it { is_expected.to be_deltas_applicable }
    end

    context 'when non commercial purposes is false' do
      subject(:user_session) { build(:duty_calculator_user_session, :deltas_applicable, planned_processing: 'commercial_purposes') }

      it { is_expected.not_to be_deltas_applicable }
    end

    context 'when not final use in ni' do
      subject(:user_session) { build(:duty_calculator_user_session, :deltas_applicable, final_use: 'no') }

      it { is_expected.not_to be_deltas_applicable }
    end

    context 'when not trader scheme' do
      subject(:user_session) { build(:duty_calculator_user_session, :deltas_applicable, trader_scheme: 'no') }

      it { is_expected.not_to be_deltas_applicable }
    end

    context 'when zero mfn duties' do
      subject(:user_session) { build(:duty_calculator_user_session, :deltas_applicable, zero_mfn_duty: true) }

      it { is_expected.not_to be_deltas_applicable }
    end

    context 'when there are trade defences in place' do
      subject(:user_session) { build(:duty_calculator_user_session, :deltas_applicable, trade_defence: true) }

      it { is_expected.not_to be_deltas_applicable }
    end

    context 'when not on the row to ni route' do
      subject(:user_session) { build(:duty_calculator_user_session, :deltas_applicable, import_destination: 'GB') }

      it { is_expected.not_to be_deltas_applicable }
    end
  end

  describe '#meursing_route?' do
    shared_examples_for 'a meursing route' do |route_trait|
      subject(:user_session) { build(:duty_calculator_user_session, route_trait) }

      it { is_expected.to be_meursing_route }
    end

    shared_examples_for 'a non-meursing route' do |route_trait|
      subject(:user_session) { build(:duty_calculator_user_session, route_trait) }

      it { is_expected.not_to be_meursing_route }
    end

    it_behaves_like 'a meursing route', :with_gb_to_ni_route
    it_behaves_like 'a meursing route', :with_row_to_ni_route

    it_behaves_like 'a non-meursing route', :with_eu_to_ni_route
    it_behaves_like 'a non-meursing route', :with_eu_to_gb_route
    it_behaves_like 'a non-meursing route', :with_row_to_gb_route
    it_behaves_like 'a non-meursing route', :with_ni_to_gb_route
  end

  describe '#import_into_gb?' do
    subject(:user_session) { build(:duty_calculator_user_session, import_destination:) }

    context 'when the import_destination is UK' do
      let(:import_destination) { 'UK' }

      it { is_expected.to be_import_into_gb }
    end

    context 'when the import_destination is not UK' do
      let(:import_destination) { 'XI' }

      it { is_expected.not_to be_import_into_gb }
    end
  end

  describe '#no_duty_to_pay?' do
    context 'when on a no duty route into ni' do
      subject(:user_session) { build(:duty_calculator_user_session, :with_no_duty_route_eu) }

      it { is_expected.to be_no_duty_to_pay }
    end

    context 'when on a no duty route into gb' do
      subject(:user_session) { build(:duty_calculator_user_session, :with_no_duty_route_gb) }

      it { is_expected.to be_no_duty_to_pay }
    end

    context 'when on a possible duty_route' do
      %i[with_possible_duty_route_into_gb with_possible_duty_route_into_ni].each do |route_trait|
        context 'when with zero_mfn_duty' do
          subject(:user_session) { build(:duty_calculator_user_session, route_trait, :zero_mfn_duty) }

          it { is_expected.to be_no_duty_to_pay }
        end

        context 'when no duty applies' do
          %w[without_any_processing commercial_processing].each do |processing|
            subject(:user_session) { build(:duty_calculator_user_session, route_trait, planned_processing: processing) }

            it { is_expected.to be_no_duty_to_pay }
          end
        end

        context 'when trader has small turnover' do
          subject(:user_session) { build(:duty_calculator_user_session, route_trait, annual_turnover: 'yes') }

          it { is_expected.to be_no_duty_to_pay }
        end

        context 'when the trader has a certificate of origin' do
          subject(:user_session) { build(:duty_calculator_user_session, route_trait, :with_certificate_of_origin) }

          it { is_expected.to be_no_duty_to_pay }
        end
      end
    end
  end

  describe '.build' do
    before do
      Thread.current[:user_session] = user_session
    end

    it 'builds a new session' do
      expect(described_class.build(foo: :bar)).to be_a(described_class)
    end

    it 'sets a new session on the current Thread' do
      expect { described_class.build(foo: :bar) }.to(change { described_class.get.object_id })
    end

    context 'when an existing session has been built' do
      before do
        previous_session
      end

      let(:previous_session) do
        described_class.build({ foo: :bar })
      end

      it 'sets a new session on the current Thread' do
        expect { described_class.build(foo: :bar) }.to(change { described_class.get.object_id })
      end
    end
  end

  describe '.build_from_params' do
    subject(:user_session) { described_class.build_from_params(session, params) }

    before do
      Thread.current[:user_session] = nil
    end

    let(:params) do
      ActionController::Parameters.new(
        commodity_code: '0702000007',
        country_of_origin:,
        import_date: '2021-01-01',
        import_destination:,
      )
    end

    let(:country_of_origin) { 'FI' }
    let(:import_destination) { 'UK' }

    let(:session) { {} }

    it { expect(user_session.import_destination).to eq('UK') }
    it { expect(user_session.commodity_source).to eq('uk') }
    it { expect(user_session.referred_service).to eq('uk') }
    it { expect(user_session.commodity_code).to eq('0702000007') }
    it { expect(user_session.import_date).to eq(Date.parse('2021-01-01')) }
    it { expect(user_session.country_of_origin).to eq('FI') }
    it { expect(user_session.other_country_of_origin).to eq('') }
    it { expect { user_session }.to change(described_class, :get).from(nil).to(an_instance_of(described_class)) }

    context 'when the import_destination is XI' do
      let(:import_destination) { 'XI' }

      it { expect(user_session.import_destination).to eq('XI') }
      it { expect(user_session.commodity_source).to eq('xi') }
      it { expect(user_session.referred_service).to eq('xi') }

      context 'when the country of origin is GB' do
        let(:country_of_origin) { 'GB' }

        it { expect(user_session.country_of_origin).to eq('GB') }
        it { expect(user_session.other_country_of_origin).to eq('') }
      end

      context 'when the country of origin is a eu member' do
        let(:country_of_origin) { 'FI' }

        it { expect(user_session.country_of_origin).to eq('FI') }
        it { expect(user_session.other_country_of_origin).to eq('') }
      end

      context 'when the country of origin is not an eu member' do
        let(:country_of_origin) { 'AR' }

        it { expect(user_session.country_of_origin).to eq('OTHER') }
        it { expect(user_session.other_country_of_origin).to eq('AR') }
      end
    end
  end

  describe '.get' do
    before do
      Thread.current[:user_session] = user_session
    end

    it 'fetches the current user session' do
      expect(described_class.get).to eq(user_session)
    end
  end

  describe '#additional_codes' do
    context 'when additional code answers have been stored' do
      subject(:user_session) do
        build(:duty_calculator_user_session, :with_additional_codes, :with_commodity_information)
      end

      it { expect(user_session.additional_codes).to eq('2340, 2600, 2340, 2600, 2601') }
    end

    context 'when additional code answers have not been stored' do
      subject(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

      it { expect(user_session.additional_codes).to eq('') }
    end
  end

  describe '#document_code_for' do
    subject(:user_session) { build(:duty_calculator_user_session, :with_document_codes) }

    it { expect(user_session.document_code_for('103', 'uk')).to eq('N851') }
  end

  describe '#additional_code_for' do
    subject(:user_session) { build(:duty_calculator_user_session, :with_additional_codes) }

    context 'with a corresponding answer on the session' do
      it { expect(user_session.additional_code_for('103', 'uk')).to eq('2600') }
    end

    context 'with no corresponding answer on the session' do
      it { expect(user_session.additional_code_for('117', 'uk')).to be_nil }
    end
  end

  describe '#excise_additional_code_for' do
    subject(:user_session) { build(:duty_calculator_user_session, :with_excise_additional_codes) }

    context 'with a corresponding answer on the session' do
      it { expect(user_session.excise_additional_code_for('306')).to eq('444') }
    end

    context 'with no corresponding answer on the session' do
      it { expect(user_session.excise_additional_code_for('LGJ')).to be_nil }
    end
  end

  describe '#measure_amount_for' do
    subject(:user_session) { build(:duty_calculator_user_session, measure_amount: { 'asvx' => :bar }) }

    it { expect(user_session.measure_amount_for('ASVX')).to eq(:bar) }
  end

  describe '#origin_country_code' do
    context 'when country of origin is OTHER' do
      subject(:origin_country_code) { build(:duty_calculator_user_session, country_of_origin: 'OTHER', other_country_of_origin: 'AD').origin_country_code }

      it { is_expected.to eq('AD') }
    end

    context 'when country of origin is not OTHER' do
      subject(:origin_country_code) { build(:duty_calculator_user_session, country_of_origin: 'AR').origin_country_code }

      it { is_expected.to eq('AR') }
    end

    context 'when country of origin is not set' do
      subject(:origin_country_code) { build(:duty_calculator_user_session).origin_country_code }

      it { is_expected.to be_nil }
    end
  end
end
