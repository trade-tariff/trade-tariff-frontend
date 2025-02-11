require 'spec_helper'

RSpec.describe Headings::ChangesController, type: :controller, vcr: { cassette_name: 'headings#0101' } do
  describe 'GET index' do
    before { get :index, params: { heading_id: '0101' }, format: :atom }

    it { is_expected.to respond_with(:success) }
    it { expect(assigns(:changeable)).to be_present }
    it { expect(assigns(:changes)).to be_a(ChangesPresenter) }
  end
end
