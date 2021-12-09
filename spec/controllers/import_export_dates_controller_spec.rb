require 'spec_helper'

RSpec.describe ImportExportDatesController, type: :controller do
  describe 'GET #show' do
    subject(:response) { get :show, params: query_params }

    context 'when there is no date in the query params' do
      let(:query_params) { {} }

      it 'initializes with todays date' do
        response

        expect(assigns(:import_export_date).import_date).to eq(Time.zone.today)
      end

      it 'attaches no error message' do
        response

        expect(assigns(:import_export_date).errors).to be_empty
      end

      it { is_expected.to render_template('import_export_dates/show') }
      it { is_expected.to have_http_status(:ok) }
    end

    context 'when there is a date in the query params' do
      let(:query_params) do
        {
          day: '1',
          month: '2',
          year: '2021',
        }
      end

      it 'initializes with todays date' do
        response

        expect(assigns(:import_export_date).import_date).to eq(Time.zone.parse('2021-02-01'))
      end

      it 'attaches no error message' do
        response

        expect(assigns(:import_export_date).errors).to be_empty
      end

      it { is_expected.to render_template('import_export_dates/show') }
      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'PATCH #update' do
    subject(:response) { patch :update, params: import_export_date_params }

    context 'when passing valid change date params' do
      let(:import_export_date_params) do
        {
          import_export_date: {
            'import_date(3i)': '1',
            'import_date(2i)': '2',
            'import_date(1i)': '2021',
          },
        }
      end

      shared_examples_for 'a valid date redirect' do |path_method, goods_nomenclature_code|
        before do
          session[:goods_nomenclature_code] = goods_nomenclature_code
        end

        it { is_expected.to redirect_to(public_send(path_method, day: '1', month: '2', year: '2021', id: goods_nomenclature_code)) }
      end

      it_behaves_like 'a valid date redirect', :sections_path, nil
      it_behaves_like 'a valid date redirect', :chapter_path, '01'
      it_behaves_like 'a valid date redirect', :heading_path, '1501'
      it_behaves_like 'a valid date redirect', :commodity_path, '2402201000'
    end

    context 'when passing invalid change date params' do
      let(:import_export_date_params) do
        {
          import_export_date: {
            'import_date(3i)': '',
            'import_date(2i)': '',
            'import_date(1i)': '',
          },
        }
      end

      it 'attaches the correct error message' do
        response

        expect(assigns(:import_export_date).errors.messages[:import_date]).to eq(['Enter a valid date'])
      end

      it 'sets the import date to nil' do
        response

        expect(assigns(:import_export_date).import_date).to be_nil
      end

      it { is_expected.to render_template('import_export_dates/show') }
      it { is_expected.to have_http_status(:ok) }
    end
  end
end
