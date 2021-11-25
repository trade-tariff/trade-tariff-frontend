require 'spec_helper'

RSpec.describe MeursingLookup::ResultsController, type: :controller do
  before do
    session[:declarable_code] = session_declarable_code
    session[:current_meursing_additional_code_id] = '706'
  end

  let(:session_declarable_code) { '1901200000' }

  describe 'GET #show' do
    subject(:do_response) { get :show, params: { id: 'foo' } }

    it { expect { do_response }.to change { session[:current_meursing_additional_code_id] }.from('706').to(nil) }
    it { is_expected.to redirect_to(commodity_path(session_declarable_code, anchor: 'import')) }
  end

  describe 'POST #create' do
    subject(:do_response) { post :create, params: { meursing_lookup_result: { meursing_additional_code_id: '707' } } }

    it { expect { do_response }.to change { session[:current_meursing_additional_code_id] }.from('706').to('707') }
    it { is_expected.to redirect_to(commodity_path(session_declarable_code, anchor: 'import')) }
  end
end
