RSpec.describe MeursingLookup::ResultsController, type: :controller do
  before do
    session[:current_meursing_additional_code_id] = '706'
  end

  let(:goods_nomenclature_code) { '1901200000' }

  describe 'GET #show' do
    subject(:do_response) do
      get :show, params: { id: 'foo', goods_nomenclature_code: }
    end

    it { expect { do_response }.to change { session[:current_meursing_additional_code_id] }.from('706').to(nil) }
    it { is_expected.to redirect_to(commodity_path(goods_nomenclature_code)) }
  end

  describe 'POST #create' do
    subject(:do_response) { post :create, params: { meursing_lookup_result: { meursing_additional_code_id: '707', goods_nomenclature_code: } } }

    it { expect { do_response }.to change { session[:current_meursing_additional_code_id] }.from('706').to('707') }
    it { is_expected.to redirect_to(commodity_path(goods_nomenclature_code)) }
  end
end
