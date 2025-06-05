RSpec.describe DutyCalculator::CommodityHelper, :user_session do
  before do
    allow(DutyCalculator::UserSession).to receive(:get).and_return(user_session)
    allow(helper).to receive(:user_session).and_return(user_session)
    allow(DutyCalculator::Api::Commodity).to receive(:build).and_call_original
    allow(commodity_context_service).to receive(:call).and_call_original
  end

  let(:commodity_context_service) { Thread.current[:commodity_context_service] }
  let(:commodity_source) { 'uk' }
  let(:commodity_code) { '0103921100' }
  let(:import_destination) { 'GB' }

  let(:user_session) do
    build(
      :duty_calculator_user_session,
      import_destination:,
      country_of_origin: 'GB',
      commodity_source:,
      commodity_code:,
    )
  end

  let(:expected_query) do
    {
      'filter[geographical_area_id]' => 'GB',
    }
  end

  describe '#filtered_commodity' do
    it 'retrieves commodities via the CommodityContextService' do
      helper.filtered_commodity

      expect(Thread.current[:commodity_context_service]).to have_received(:call).with(commodity_source, commodity_code, expected_query)
    end

    context 'when the commodity source is passed' do
      it 'uses the passed commodity source' do
        helper.filtered_commodity(source: 'uk')

        expect(DutyCalculator::Api::Commodity).to have_received(:build).with(
          'uk',
          commodity_code,
          expected_query,
        )
      end
    end

    context 'when `OTHER` is used as the country_of_origin' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          import_destination:,
          country_of_origin: 'OTHER',
          commodity_source:,
          commodity_code:,
          other_country_of_origin: 'AR',
        )
      end

      it 'uses the other_country_of_origin value for the filter' do
        helper.filtered_commodity

        expect(DutyCalculator::Api::Commodity).to have_received(:build).with(
          commodity_source,
          commodity_code,
          { 'filter[geographical_area_id]' => 'AR' },
        )
      end
    end

    context 'when the source is xi and a meursing_additional_code is set' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_gb_to_ni_route,
          :with_commodity_information,
          :with_meursing_additional_code,
          commodity_source: 'xi',
        )
      end

      it 'passes the correct query filter to the commodity context service' do
        helper.filtered_commodity

        expect(DutyCalculator::Api::Commodity).to have_received(:build).with(
          'xi',
          '0702000007',
          'filter[geographical_area_id]' => 'GB', 'filter[meursing_additional_code_id]' => '000',
        )
      end
    end
  end

  describe '#uk_filtered_commodity' do
    it 'calls the commodity service with the uk as an argument' do
      helper.uk_filtered_commodity
      expect(commodity_context_service).to have_received(:call).with('uk', anything, anything)
    end
  end

  describe '#xi_filtered_commodity' do
    it 'calls the commodity service with the uk as an argument' do
      helper.xi_filtered_commodity
      expect(commodity_context_service).to have_received(:call).with('xi', anything, anything)
    end

    context 'when a meursing_additional_code is set' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_gb_to_ni_route,
          :with_commodity_information,
          :with_meursing_additional_code,
          commodity_source: 'xi',
        )
      end

      it 'passes a meursing_additional_code_id filter' do
        helper.xi_filtered_commodity

        expect(commodity_context_service).to have_received(:call).with('xi', anything, 'filter[geographical_area_id]' => 'GB', 'filter[meursing_additional_code_id]' => '000')
      end
    end
  end

  describe '#commodity' do
    let(:user_session) do
      build(
        :duty_calculator_user_session,
        import_destination:,
        commodity_source:,
        commodity_code:,
      )
    end

    let(:expected_query) { {} }

    it 'retrieves commodities via the CommodityContextService' do
      helper.commodity

      expect(Thread.current[:commodity_context_service]).to have_received(:call).with(commodity_source, commodity_code, expected_query)
    end

    it 'returns an unfiltered commodity' do
      helper.commodity

      expect(DutyCalculator::Api::Commodity).to have_received(:build).with(
        commodity_source,
        commodity_code,
        expected_query,
      )
    end
  end

  describe '#applicable_meursing_codes?' do
    it { expect(helper.applicable_meursing_codes?).to be(true) }

    it 'passes xi to the Commodity builder' do
      helper.applicable_meursing_codes?

      expect(DutyCalculator::Api::Commodity).to have_received(:build).with('xi', anything, anything)
    end
  end

  describe '#applicable_vat_options' do
    let(:expected_options) do
      {
        'VAT' => 'Value added tax (20.0)',
        'VATR' => 'VAT reduced rate 5% (5.0)',
        'VATZ' => 'VAT zero rate (0.0)',
      }
    end

    it 'returns the applicable vat options' do
      expect(helper.applicable_vat_options).to eq(expected_options)
    end

    it 'always fetches data from the uk source' do
      helper.applicable_vat_options

      expect(DutyCalculator::Api::Commodity).to have_received(:build).with(
        'uk',
        commodity_code,
        expected_query,
      )
    end
  end

  describe '#applicable_additional_codes' do
    let(:expected_options) do
      {
        'uk' => {
          '105' => {
            'additional_codes' => [
              {
                'code' => '2600',
                'hint' => "Read more about the <a target='_blank' href='https://www.gov.uk/government/news/hmg-suspends-import-tariffs-on-covid-19-products-to-fight-virus'>suspension of tariffs on COVID-19 critical goods [opens in a new browser window]</a>",
                'measure_sid' => 20_126_513,
                'overlay' => 'The product I am importing is COVID-19 critical',
              },
              {
                'code' => '2601',
                'hint' => '',
                'measure_sid' => 20_126_512,
                'overlay' => 'The product I am importing is not COVID-19 critical',
              },
            ],
            'heading' => {
              'hint' => 'To trade this commodity, you need to specify an additional 4 digits, known as an additional code',
              'overlay' => 'Describe your goods in more detail',
            },
            'measure_type_description' => 'Non preferential duty under authorised use',
          },
        },
      }
    end

    it 'returns the applicable additional codes' do
      expect(helper.applicable_additional_codes).to eq(expected_options)
    end
  end

  describe '#applicable_excise_additional_codes' do
    let(:expected_options) do
      {
        '306' => {
          'measure_type_description' => 'Excises',
          'heading' => nil,
          'additional_codes' => [
            {
              'code' => 'X520',
              'overlay' => '520 - Light oil: unrebated (unmarked) – other unrebated light oil',
              'hint' => '',
              'measure_sid' => -485_461,
            },
            {
              'code' => 'X522',
              'overlay' => '522 - Light oil: rebated – unleaded petrol',
              'hint' => '',
              'measure_sid' => -485_453,
            },
            {
              'code' => 'X541',
              'overlay' => '541 - Heavy oil: unrebated (unmarked, including Diesel Engine Road Vehicle (DERV) or road fuel extender and unmarked kerosene or unmarked gas oil for which no marking waiver has been granted)',
              'hint' => '',
              'measure_sid' => -485_455,
            },
            {
              'code' => 'X542',
              'overlay' => '542 - Heavy oil: kerosene to be used as motor fuel off road or in an excepted vehicle',
              'hint' => '',
              'measure_sid' => -485_456,
            },
            {
              'code' => 'X551',
              'overlay' => '551 - Heavy oil: kerosene (marked or unmarked under marking waiver, including heavy oil aviation turbine fuel) to be used other than as motor fuel off-road or in an excepted vehicle',
              'hint' => '',
              'measure_sid' => -485_457,
            },
            {
              'code' => 'X556',
              'overlay' => '556 - Heavy oil: gas oil (marked or unmarked under marking waiver)',
              'hint' => '',
              'measure_sid' => -485_458,
            },
            {
              'code' => 'X561',
              'overlay' => '561 - Heavy oil: fuel oil (unmarked)',
              'hint' => '',
              'measure_sid' => -485_459,
            },
            {
              'code' => 'X570',
              'overlay' => '570 - Heavy oil: other (unmarked)',
              'hint' => '',
              'measure_sid' => -485_460,
            },
            {
              'code' => 'X611',
              'overlay' => '611 - Cigarettes',
              'hint' => '',
              'measure_sid' => -1_010_806_389,
            },
          ],
        },
      }
    end

    it 'returns the applicable additional codes' do
      expect(helper.applicable_excise_additional_codes).to eq(expected_options)
    end
  end

  describe '#applicable_document_codes' do
    before do
      allow(DutyCalculator::ApplicableDocumentCodesService).to receive(:new).and_call_original
    end

    let(:expected_options) do
      {
        'uk' => {
          '103' => [{ code: 'N851', description: 'N851 - ' }, { code: 'None', description: 'None of the above' }],
          '105' => [{ code: 'C644', description: 'C644 - ' }, { code: 'Y929', description: 'Y929 - ' }, { code: 'None', description: 'None of the above' }],
        },
      }
    end

    it { expect(helper.applicable_document_codes).to eq(expected_options) }

    it 'calls out to the ApplicableDocumentCodesService' do
      helper.applicable_document_codes

      expect(DutyCalculator::ApplicableDocumentCodesService).to have_received(:new)
    end
  end

  describe '#applicable_measure_units' do
    before do
      allow(DutyCalculator::ApplicableMeasureUnitMerger).to receive(:new).and_call_original
    end

    it 'calls the DutyCalculator::ApplicableMeasureUnitMerger service' do
      helper.applicable_measure_units

      expect(DutyCalculator::ApplicableMeasureUnitMerger).to have_received(:new)
    end
  end

  describe '#applicable_measure_unit_keys' do
    let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

    it 'returns the keys of the applicable_measure_units' do
      expect(helper.applicable_measure_unit_keys).to eq(%w[dtn])
    end
  end

  describe '#applicable_measure_type_ids' do
    it { expect(helper.applicable_measure_type_ids).to eq(%w[105]) }
  end

  describe '#applicable_excise_measure_type_ids' do
    it { expect(helper.applicable_excise_measure_type_ids).to eq(%w[306]) }
  end

  describe '#applicable_additional_codes?' do
    context 'when the commodity has no additional codes' do
      let(:commodity_code) { '0102291010' }

      it { expect(helper).not_to be_applicable_additional_codes }
    end

    context 'when the commodity has additional codes' do
      let(:commodity_code) { '0809400500' }

      it { expect(helper).to be_applicable_additional_codes }
    end
  end

  describe '#applicable_excise_additional_codes?' do
    context 'when the commodity has no additional codes' do
      let(:commodity_code) { '0102291010' }

      it { expect(helper).not_to be_applicable_excise_additional_codes }
    end

    context 'when the commodity has additional codes' do
      let(:commodity_code) { '0809400500' }

      it { expect(helper).to be_applicable_excise_additional_codes }
    end
  end
end
