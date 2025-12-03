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
        allow(controller).to receive(:current_user).and_return(user)
        get :new
      end

      it { is_expected.to respond_with(:success) }
    end
  end

  describe 'GET #active' do
    before do
      allow(controller).to receive_messages(current_user: user, get_subscription: subscription)
    end

    it_behaves_like 'a commodity category page', :active, 'active'
  end

  describe 'GET #expired' do
    before do
      allow(controller).to receive_messages(current_user: user, get_subscription: subscription)
    end

    it_behaves_like 'a commodity category page', :expired, 'expired'
  end

  describe 'GET #invalid' do
    before do
      allow(controller).to receive_messages(current_user: user, get_subscription: subscription)
    end

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
        let(:grouped_measure_changes) { [TariffChanges::GroupedMeasureChange.new] }
        let(:commodity_changes) { [TariffChanges::CommodityChange.new] }

        before do
          allow(TariffChanges::GroupedMeasureChange).to receive(:all).and_return(grouped_measure_changes)
          allow(TariffChanges::CommodityChange).to receive(:all).and_return(commodity_changes)
          get :index
        end

        it { is_expected.to respond_with(:success) }

        it { expect(assigns(:meta).total).to eq(subscription.meta.values.flatten.size) }
        it { expect(assigns(:meta).active).to eq(subscription.meta[:active].count) }
        it { expect(assigns(:meta).expired).to eq(subscription.meta[:expired].count) }
        it { expect(assigns(:meta).invalid).to eq(subscription.meta[:invalid].count) }

        it 'assigns @grouped_measure_changes' do
          expect(assigns(:grouped_measure_changes)).to eq(grouped_measure_changes)
        end

        it 'assigns @commodity_changes' do
          expect(assigns(:commodity_changes)).to eq(commodity_changes)
        end
      end

      context 'when user does not have a my commodities subscription' do
        before do
          allow(controller).to receive(:get_subscription).and_return(nil)
          get :index
        end

        it { is_expected.to redirect_to(myott_path) }
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
          expect(assigns(:alert)).to eq('Please upload a csv/excel file')
        end

        it 'renders the new template again' do
          expect(response).to render_template(:new)
        end
      end
    end
  end
end
