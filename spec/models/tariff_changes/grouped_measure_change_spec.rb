require 'spec_helper'

RSpec.describe TariffChanges::GroupedMeasureChange do
  let(:token) { 'valid_token' }
  let(:params) { {} }
  let(:collection_path) { '/uk/user/grouped_measure_changes' }
  let(:headers) { { authorization: "Bearer #{token}" } }

  describe '.find' do
    let(:id) { 'export_RU_' }
    let(:singular_path) { '/uk/user/grouped_measure_changes/:id' }
    let(:api_client) { instance_double(Faraday::Connection) }
    let(:commodity_changes) do
      [
        build(:grouped_measure_commodity_change),
        build(:grouped_measure_commodity_change),
        build(:grouped_measure_commodity_change),
      ]
    end

    before do
      allow(described_class).to receive(:api).and_return(api_client)
      allow(described_class).to receive(:headers).with(token).and_return(headers)
    end

    context 'when token is nil and not in development' do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it 'returns nil' do
        expect(described_class.find(id, nil, {})).to be_nil
      end
    end

    context 'when token is provided' do
      let(:faraday_response) { instance_double(Faraday::Response, body: response_body) }

      before do
        allow(api_client).to receive(:get).and_return(faraday_response)
      end

      context 'without pagination metadata' do
        let(:response_body) do
          {
            'data' => {
              'id' => id,
              'type' => 'grouped_measure_change',
              'attributes' => {},
              'relationships' => {
                'grouped_measure_commodity_changes' => {
                  'data' => commodity_changes.map { |c| { 'id' => c.resource_id, 'type' => 'grouped_measure_commodity_change' } },
                },
              },
            },
            'included' => commodity_changes.map do |c|
              {
                'id' => c.resource_id,
                'type' => 'grouped_measure_commodity_change',
                'attributes' => {
                  'count' => c.count,
                  'impacted_measures' => c.impacted_measures,
                },
              }
            end,
          }
        end

        it 'returns the record' do
          result = described_class.find(id, token, {})
          expect(result).to be_a(described_class)
        end

        it 'does not paginate the collection', :aggregate_failures do
          result = described_class.find(id, token, {})
          expect(result.grouped_measure_commodity_changes).to be_an(Array)
          expect(result.grouped_measure_commodity_changes).not_to be_a(Kaminari::PaginatableArray)
        end
      end

      context 'with pagination metadata' do
        let(:response_body) do
          {
            'data' => {
              'id' => id,
              'type' => 'grouped_measure_change',
              'attributes' => {},
              'relationships' => {
                'grouped_measure_commodity_changes' => {
                  'data' => commodity_changes.map { |c| { 'id' => c.resource_id, 'type' => 'grouped_measure_commodity_change' } },
                },
              },
            },
            'meta' => {
              'pagination' => {
                'page' => 2,
                'per_page' => 10,
                'total_count' => 150,
              },
            },
            'included' => commodity_changes.map do |c|
              {
                'id' => c.resource_id,
                'type' => 'grouped_measure_commodity_change',
                'attributes' => {
                  'count' => c.count,
                  'impacted_measures' => c.impacted_measures,
                },
              }
            end,
          }
        end

        it 'paginates the collection with metadata', :aggregate_failures do
          result = described_class.find(id, token, { page: 2, per_page: 10 })
          expect(result.grouped_measure_commodity_changes).to be_a(Kaminari::PaginatableArray)
          expect(result.grouped_measure_commodity_changes.current_page).to eq(2)
          expect(result.grouped_measure_commodity_changes.total_count).to eq(150)
        end

        it 'calls API with correct path and options' do
          described_class.find(id, token, { page: 2, per_page: 10 })
          expect(api_client).to have_received(:get).with(
            '/uk/user/grouped_measure_changes/export_RU_',
            { page: 2, per_page: 10 },
            headers,
          )
        end
      end
    end
  end

  describe '.all' do
    context 'when token is provided' do
      let(:collection_data) do
        [
          build(:grouped_measure_change, trade_direction: 'import').tap do |item|
            allow(item).to receive(:geographical_area_description).and_return('United Kingdom')
          end,
          build(:grouped_measure_change, trade_direction: 'export').tap do |item|
            allow(item).to receive(:geographical_area_description).and_return('European Union')
          end,
          build(:grouped_measure_change, trade_direction: 'import').tap do |item|
            allow(item).to receive(:geographical_area_description).and_return('Australia')
          end,
        ]
      end

      before do
        allow(described_class).to receive_messages(
          collection: collection_data,
          headers: headers,
        )
      end

      it 'calls collection with correct parameters' do
        described_class.all(token, params)

        expect(described_class).to have_received(:collection)
          .with(collection_path, params, headers)
      end

      it 'sorts by trade_direction then geographical_area_description' do
        result = described_class.all(token, params)

        expect(result.map(&:trade_direction)).to eq(%w[import import export])
      end

      it 'sorts geographical areas correctly within same trade direction' do
        result = described_class.all(token, params)

        import_results = result.select { |r| r.trade_direction == 'import' }
        expect(import_results.map(&:geographical_area_description)).to eq(['Australia', 'United Kingdom'])
      end

      it 'returns an array' do
        result = described_class.all(token, params)
        expect(result).to be_an(Array)
      end
    end

    context 'when token is nil and not in development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it 'returns empty array' do
        result = described_class.all(nil, params)
        expect(result).to eq([])
      end

      it 'does not call collection method' do
        allow(described_class).to receive(:collection)
        described_class.all(nil, params)
        expect(described_class).not_to have_received(:collection)
      end
    end

    context 'when token is nil but in development environment' do
      let(:collection_data) { [] }

      before do
        allow(Rails.env).to receive(:development?).and_return(true)
        allow(described_class).to receive_messages(
          collection: collection_data,
          headers: headers,
        )
      end

      it 'calls collection method' do
        described_class.all(nil, params)
        expect(described_class).to have_received(:collection)
      end
    end

    context 'when Faraday::UnauthorizedError is raised' do
      before do
        allow(described_class).to receive(:collection).and_raise(Faraday::UnauthorizedError)
        allow(described_class).to receive(:headers).and_return(headers)
      end

      it 'returns empty array' do
        result = described_class.all(token, params)
        expect(result).to eq([])
      end
    end

    context 'with date parameter' do
      let(:date) { Date.current }
      let(:params) { { as_of: date } }
      let(:collection_data) { [] }

      before do
        allow(described_class).to receive_messages(
          collection: collection_data,
          headers: headers,
        )
      end

      it 'passes date parameter to collection' do
        described_class.all(token, params)
        expect(described_class).to have_received(:collection)
          .with(collection_path, params, headers)
      end
    end
  end

  describe '#geographical_area_description' do
    let(:grouped_measure_change) { build(:grouped_measure_change) }

    before do
      # Mock the geographical_area to have the expected long_description
      allow(grouped_measure_change).to receive(:geographical_area).and_return(
        instance_double(GeographicalArea, long_description: 'United Kingdom'),
      )
    end

    context 'without excluded countries' do
      before do
        allow(grouped_measure_change).to receive(:excluded_country_list).and_return('')
      end

      it 'returns the geographical area long description' do
        expect(grouped_measure_change.geographical_area_description).to eq('United Kingdom')
      end
    end

    context 'with excluded countries' do
      before do
        allow(grouped_measure_change).to receive(:excluded_country_list).and_return('France, Germany')
      end

      it 'returns description with exclusions' do
        expected = 'United Kingdom excluding France, Germany'
        expect(grouped_measure_change.geographical_area_description).to eq(expected)
      end
    end

    context 'with blank excluded countries list' do
      before do
        allow(grouped_measure_change).to receive(:excluded_country_list).and_return('   ')
      end

      it 'returns only the geographical area description' do
        expect(grouped_measure_change.geographical_area_description).to eq('United Kingdom')
      end
    end
  end

  describe 'concerns' do
    it 'includes AuthenticatableApiEntity' do
      expect(described_class.included_modules).to include(AuthenticatableApiEntity)
    end

    it 'includes HasExcludedCountries' do
      expect(described_class.included_modules).to include(HasExcludedCountries)
    end
  end

  describe 'attributes' do
    let(:instance) { build(:grouped_measure_change) }

    it 'has trade_direction accessor' do
      instance.trade_direction = 'import'
      expect(instance.trade_direction).to eq('import')
    end

    it 'has count accessor' do
      instance.count = 5
      expect(instance.count).to eq(5)
    end
  end

  describe 'associations' do
    let(:instance) { build(:grouped_measure_change) }

    it 'has one geographical_area' do
      expect(instance).to respond_to(:geographical_area)
    end

    it 'has many excluded_countries' do
      expect(instance).to respond_to(:excluded_countries)
    end

    it 'has many grouped_measure_commodity_changes' do
      expect(instance).to respond_to(:grouped_measure_commodity_changes)
    end
  end

  describe '#trade_direction_description' do
    let(:instance) { build(:grouped_measure_change) }

    it 'returns Imports and exports for both' do
      instance.trade_direction = 'both'
      expect(instance.trade_direction_description).to eq('Imports and exports')
    end

    it 'returns Imports for import' do
      instance.trade_direction = 'import'
      expect(instance.trade_direction_description).to eq('Imports')
    end

    it 'returns Exports for export' do
      instance.trade_direction = 'export'
      expect(instance.trade_direction_description).to eq('Exports')
    end
  end
end
