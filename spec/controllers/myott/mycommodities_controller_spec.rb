require 'spec_helper'

RSpec.describe Myott::MycommoditiesController, type: :controller do
  let(:user) do
    build(:user,
          my_commodities_subscription: true)
  end
  let(:subscription) do
    build(:subscription,
          active: true,
          subscription_type: 'my_commodities',
          metadata: { commodity_codes: %w[1111111111 22222222222 3333333333 4444444444 5555555555] },
          meta: { active: %w[1111111111 22222222222], expired: %w[33333333333 44444444444], invalid: %w[55555555555] })
  end

  before do
    allow(Subscription).to receive(:find).and_return(subscription)
  end

  describe 'GET #new' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :new
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        session[:commodity_codes_key] = 'submission:commodity_codes:123abc'
        Rails.cache.write('submission:commodity_codes:123abc', {
          'active_commodity_codes' => subscription.meta[:active],
          'expired_commodity_codes' => subscription.meta[:expired],
          'invalid_commodity_codes' => subscription.meta[:invalid],
        })
        allow(controller).to receive(:current_user).and_return(user)
        get :new
      end

      it { is_expected.to respond_with(:success) }

      it 'deletes commodity_codes_key from the session' do
        expect(session[:commodity_codes_key]).to be_nil
      end

      it 'deletes any commodity codes from the redis cache' do
        expect(Rails.cache.read('submission:commodity_codes:123abc')).to be_nil
      end
    end
  end

  describe 'GET #active' do
    it_behaves_like 'a commodity category page', :active, 'active'
  end

  describe 'GET #expired' do
    it_behaves_like 'a commodity category page', :expired, 'expired'
  end

  describe 'GET #invalid' do
    it_behaves_like 'a commodity category page', :invalid, 'invalid'
  end

  describe 'GET #index' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :new
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive_messages(current_user: user, get_subscription: subscription)
      end

      context 'when commodity codes are present' do
        before do
          allow(Rails.cache).to receive(:read).and_return({
            'active_commodity_codes' => subscription.meta[:active],
            'expired_commodity_codes' => subscription.meta[:expired],
            'invalid_commodity_codes' => subscription.meta[:invalid],
          })

          get :index
        end

        it { is_expected.to respond_with(:success) }

        it { expect(assigns(:active_commodity_codes)).to eq(subscription.meta[:active]) }
        it { expect(assigns(:expired_commodity_codes)).to eq(subscription.meta[:expired]) }
        it { expect(assigns(:invalid_commodity_codes)).to eq(subscription.meta[:invalid]) }
      end

      context 'when user does not have a my commodities subscription' do
        before do
          allow(controller).to receive(:get_subscription).and_return(nil)
          get :index
        end

        it { is_expected.to redirect_to(new_myott_mycommodity_path) }
      end
    end
  end

  describe 'POST #create' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        post :create, params: { fileUpload1: nil }
      end

      it 'redirects to the identity login page' do
        expect(response).to redirect_to('http://localhost:3005/myott')
      end
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        cookies[:id_token] = 'valid-jwt-token'
      end

      context 'when the file is a valid csv' do
        it_behaves_like 'a valid commodity file upload',
                        'myott/mycommodities_files/valid_csv_file.csv',
                        'text/csv'
      end

      context 'when the file is an invalid csv' do
        it_behaves_like 'an invalid commodity file upload',
                        'myott/mycommodities_files/invalid_csv_file.csv',
                        'text/csv'
      end

      context 'when the file is a valid excel' do
        it_behaves_like 'a valid commodity file upload',
                        'myott/mycommodities_files/valid_excel_file.xlsx',
                        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end

      context 'when the file is an invalid excel' do
        it_behaves_like 'an invalid commodity file upload',
                        'myott/mycommodities_files/invalid_excel_file.xlsx',
                        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end

      context 'when there is no file' do
        before do
          post :create, params: { fileUpload1: nil }
        end

        it 'sets an alert' do
          expect(assigns(:alert)).to eq('Please upload a file using the Choose file button or drag and drop.')
        end

        it 'renders the new template again' do
          expect(response).to render_template(:new)
        end
      end

      context 'when the file is an invalid file type' do
        let(:invalid_file) { fixture_file_upload('myott/mycommodities_files/invalid_file_type.txt', 'text/plain') }

        before do
          post :create, params: { fileUpload1: invalid_file }
        end

        it 'sets an alert' do
          expect(assigns(:alert)).to eq('please upload a csv/excel file')
        end

        it 'renders the new template again' do
          expect(response).to render_template(:new)
        end
      end
    end
  end
end
