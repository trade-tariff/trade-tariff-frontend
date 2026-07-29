require 'spec_helper'

RSpec.describe 'Goods nomenclature context', type: :request do
  describe 'GET /import_export_dates' do
    [
      '1x',
      '19x1',
      '803909000',
      '190120000x',
      '1901200000-1x',
      'invalid-id',
      %w[1901200000],
      { code: '1901200000' },
    ].each do |goods_nomenclature_code|
      context "with #{goods_nomenclature_code.inspect}" do
        it 'returns not found' do
          get import_export_dates_path, params: { goods_nomenclature_code: }

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    [nil, '', '19', '1901', '1901200000', '1901200000-10'].each do |goods_nomenclature_code|
      context "with #{goods_nomenclature_code.inspect}" do
        it 'preserves valid contexts' do
          get import_export_dates_path, params: { goods_nomenclature_code: }

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe 'GET /geographical_areas/:id' do
    it 'rejects before loading the area' do
      get geographical_area_path('1013'), params: { goods_nomenclature_code: '803909000' }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /measure_types/:id/preference_codes/:id' do
    it 'rejects before loading preference data' do
      get measure_type_preference_code_path(measure_type_id: '103', id: '100'),
          params: { goods_nomenclature_code: '803909000' }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /meursing_lookup/steps/:id' do
    it 'rejects invalid context' do
      get meursing_lookup_step_path(:start), params: { goods_nomenclature_code: '803909000' }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /meursing_lookup/result' do
    it 'rejects invalid context' do
      get meursing_lookup_result_path, params: { goods_nomenclature_code: '803909000' }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /meursing_lookup/result' do
    it 'rejects invalid nested context' do
      post meursing_lookup_result_path,
           params: {
             meursing_lookup_result: {
               goods_nomenclature_code: '803909000',
               meursing_additional_code_id: '707',
             },
           }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /import_export_dates' do
    it 'rejects invalid nested context' do
      patch import_export_dates_path,
            params: {
              import_export_date: {
                'import_date(1i)': '2026',
                'import_date(2i)': '7',
                'import_date(3i)': '29',
                goods_nomenclature_code: '803909000',
              },
            }

      expect(response).to have_http_status(:not_found)
    end

    it 'does not mask invalid nested context' do
      patch import_export_dates_path,
            params: {
              goods_nomenclature_code: '',
              import_export_date: {
                'import_date(1i)': '2026',
                'import_date(2i)': '7',
                'import_date(3i)': '29',
                goods_nomenclature_code: '803909000',
              },
            }

      expect(response).to have_http_status(:not_found)
    end
  end
end
