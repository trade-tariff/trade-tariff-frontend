RSpec.describe DutyCalculator::ConfirmationDecorator, :user_session do
  subject(:confirmation_decorator) { described_class.new(confirmation_step) }

  let(:confirmation_step) { DutyCalculator::Steps::Confirmation.new }

  let(:user_session) do
    build(
      :duty_calculator_user_session,
      :with_commodity_information,
      :with_import_date,
      :with_import_destination,
      :with_country_of_origin,
      :without_trader_scheme,
      :with_large_turnover,
      :with_planned_processing,
      :with_certificate_of_origin,
      :with_customs_value,
      :with_coerced_measure_amount,
      :with_additional_codes,
      :with_excise_additional_codes,
      :with_meursing_additional_code,
      :with_vat,
      :with_document_codes,
      commodity_code:,
    )
  end

  let(:commodity_code) { '0103921100' }

  describe 'ORDERED_STEPS' do
    it 'returns the correct steps' do
      expect(described_class::ORDERED_STEPS).to eq(
        %w[
          additional_code
          document_code
          import_date
          import_destination
          country_of_origin
          trader_scheme
          final_use
          annual_turnover
          planned_processing
          certificate_of_origin
          meursing_additional_code
          customs_value
          measure_amount
          excise
          vat
        ],
      )
    end
  end

  describe '#user_answers' do
    let(:expected) do
      [
        { key: 'additional_code', label: 'Additional code(s)', value: '2340, 2600, 2340, 2600, 2601' },
        { key: 'document_code', label: 'Document(s)', value: 'C644, N851, Y929' },
        { key: 'import_date', label: 'Date of import', value: '1 January 2025' },
        { key: 'import_destination', label: 'Destination', value: 'Northern Ireland' },
        { key: 'country_of_origin', label: 'Coming from', value: 'United Kingdom' },
        { key: 'trader_scheme', label: 'Trader scheme', value: 'No' },
        { key: 'annual_turnover', label: 'Annual turnover', value: '£2,000,000 or more' },
        { key: 'planned_processing', label: 'Processing', value: 'Commercial purposes' },
        { key: 'certificate_of_origin', label: 'Certificate of origin', value: 'Yes' },
        { key: 'meursing_additional_code', label: 'Meursing Code', value: '000' },
        { key: 'customs_value', label: 'Customs value', value: '£1,200.00' },
        { key: 'measure_amount', label: 'Import quantity', value: '<div id="measure-kgm"><span title="What is the weight of the goods you will be importing?"><b>kilograms</b></span><br>100</div>' },
        { key: 'excise', label: 'Excise additional code', value: '444, 369' },
        { key: 'vat', label: 'Applicable VAT rate', value: 'VAT zero rate (0.0)' },
      ]
    end

    it 'returns an array with formatted user answers from the session' do
      expect(confirmation_decorator.user_answers).to eq(expected)
    end

    context 'when no document code has been selected' do
      let(:user_session) { build(:duty_calculator_user_session, :with_no_document_code_selected) }

      let(:expected) do
        [
          { key: 'document_code', label: 'Document(s)', value: 'n/a' },
        ]
      end

      it 'returns n/a for documents line' do
        expect(confirmation_decorator.user_answers).to eq(expected)
      end
    end
  end

  describe '#path_for' do
    shared_examples_for 'a valid path_for call' do |path_entity, expected_path|
      it { expect(confirmation_decorator.path_for(key: path_entity)).to eq(expected_path) }
    end

    it_behaves_like 'a valid path_for call', :additional_code, '/duty-calculator/additional-codes/105'
    it_behaves_like 'a valid path_for call', :annual_turnover, '/duty-calculator/annual-turnover'
    it_behaves_like 'a valid path_for call', :certificate_of_origin, '/duty-calculator/certificate-of-origin'
    it_behaves_like 'a valid path_for call', :country_of_origin, '/duty-calculator/country-of-origin'
    it_behaves_like 'a valid path_for call', :customs_value, '/duty-calculator/customs-value'
    it_behaves_like 'a valid path_for call', :document_code, '/duty-calculator/document-codes/103'
    it_behaves_like 'a valid path_for call', :excise, '/duty-calculator/excise/306'
    it_behaves_like 'a valid path_for call', :final_use, '/duty-calculator/final-use'
    it_behaves_like 'a valid path_for call', :import_date, '/duty-calculator/uk/0103921100/import-date'
    it_behaves_like 'a valid path_for call', :import_destination, '/duty-calculator/import-destination'
    it_behaves_like 'a valid path_for call', :measure_amount, '/duty-calculator/measure-amount'
    it_behaves_like 'a valid path_for call', :meursing_additional_code, '/duty-calculator/meursing-additional-codes'
    it_behaves_like 'a valid path_for call', :planned_processing, '/duty-calculator/planned-processing'
    it_behaves_like 'a valid path_for call', :trader_scheme, '/duty-calculator/trader-scheme'
    it_behaves_like 'a valid path_for call', :vat, '/duty-calculator/vat'
  end
end
