require 'spec_helper'

RSpec.describe MeursingLookup::ResultsController, type: :controller do
  before do
    session[:goods_nomenclature_code] = session_goods_nomenclature_code
    session[:current_meursing_additional_code_id] = '706'
  end

  let(:session_goods_nomenclature_code) { '1901200000' }

  describe 'GET #show' do
    subject(:do_response) { get :show, params: { id: 'foo' } }

    it { expect { do_response }.to change { session[:current_meursing_additional_code_id] }.from('706').to(nil) }
    it { is_expected.to redirect_to(commodity_path(session_goods_nomenclature_code)) }
  end

  describe 'POST #create' do
    subject(:do_response) { post :create, params: { meursing_lookup_result: { meursing_additional_code_id: '707' } } }

    it { expect { do_response }.to change { session[:current_meursing_additional_code_id] }.from('706').to('707') }
    it { is_expected.to redirect_to(commodity_path(session_goods_nomenclature_code)) }
  end
end
