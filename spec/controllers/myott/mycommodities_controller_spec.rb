RSpec.describe Myott::MycommoditiesController, type: :controller do
  include MyottAuthenticationHelpers

  def stub_get_subscription(subscription_type, subscription = nil)
    allow(controller).to receive(:get_subscription).with(subscription_type).and_return(subscription)
    subscription
  end

  let(:user) { build(:user, my_commodities_subscription: true) }
  let(:subscription) { build(:subscription, :my_commodities) }

  before do
    allow(Subscription).to receive(:find).and_return(subscription)
  end

  describe 'GET #new' do
    it_behaves_like 'a protected myott page', :new
  end

  describe 'GET #active' do
    before do
      stub_authenticated_user(user)
      stub_get_subscription('my_commodities', subscription)
    end

    it_behaves_like 'a commodity category page', :active
  end

  describe 'GET #expired' do
    before do
      stub_authenticated_user(user)
      stub_get_subscription('my_commodities', subscription)
    end

    it_behaves_like 'a commodity category page', :expired
  end

  describe 'GET #invalid' do
    before do
      stub_authenticated_user(user)
      stub_get_subscription('my_commodities', subscription)
    end

    it_behaves_like 'a commodity category page', :invalid
  end

  describe 'GET #index' do
    it_behaves_like 'a protected myott page', :index

    context 'when current_user is valid' do
      before do
        stub_authenticated_user(user)
        stub_get_subscription('my_commodities', subscription)
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

        it { expect(assigns(:commodity_code_counts).total).to eq(subscription.meta[:counts]['total']) }
        it { expect(assigns(:commodity_code_counts).active).to eq(subscription.meta[:counts]['active']) }
        it { expect(assigns(:commodity_code_counts).expired).to eq(subscription.meta[:counts]['expired']) }
        it { expect(assigns(:commodity_code_counts).invalid).to eq(subscription.meta[:counts]['invalid']) }

        it 'assigns @grouped_measure_changes' do
          expect(assigns(:grouped_measure_changes)).to eq(grouped_measure_changes)
        end

        it 'assigns @commodity_changes' do
          expect(assigns(:commodity_changes)).to eq(commodity_changes)
        end
      end

      context 'when user does not have a my commodities subscription' do
        before do
          stub_get_subscription('my_commodities', nil)
          get :index
        end

        it { is_expected.to redirect_to(new_myott_mycommodity_path) }
      end

      context 'when subscription meta is nil' do
        let(:subscription_with_nil_meta) do
          build(:subscription, :my_commodities, meta: nil)
        end

        before do
          stub_get_subscription('my_commodities', subscription_with_nil_meta)
          allow(TariffChanges::GroupedMeasureChange).to receive(:all).and_return([])
          allow(TariffChanges::CommodityChange).to receive(:all).and_return([])
          get :index
        end

        it { is_expected.to respond_with(:success) }

        it 'assigns default meta values', :aggregate_failures do
          expect(assigns(:commodity_code_counts).total).to eq(0)
          expect(assigns(:commodity_code_counts).active).to eq(0)
          expect(assigns(:commodity_code_counts).expired).to eq(0)
          expect(assigns(:commodity_code_counts).invalid).to eq(0)
        end
      end

      context 'when subscription counts is missing' do
        let(:subscription_without_counts) do
          build(:subscription, :my_commodities,
                meta: { some_other_key: 'value' })
        end

        before do
          stub_get_subscription('my_commodities', subscription_without_counts)
          allow(TariffChanges::GroupedMeasureChange).to receive(:all).and_return([])
          allow(TariffChanges::CommodityChange).to receive(:all).and_return([])
          get :index
        end

        it { is_expected.to respond_with(:success) }

        it 'assigns default meta values', :aggregate_failures do
          expect(assigns(:commodity_code_counts).total).to eq(0)
          expect(assigns(:commodity_code_counts).active).to eq(0)
          expect(assigns(:commodity_code_counts).expired).to eq(0)
          expect(assigns(:commodity_code_counts).invalid).to eq(0)
        end
      end
    end
  end

  describe 'POST #create' do
    it_behaves_like 'a protected myott page', :create

    context 'when current_user is valid' do
      before do
        stub_authenticated_user(user)
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
          post :create, params: { myott_commodity_upload_form: { file: nil } }
        end

        it 'adds a validation error to the form' do
          expect(assigns(:upload_form).errors[:file]).to include('Select a file in a CSV or XLSX format')
        end

        it 'renders the new template again' do
          expect(response).to render_template(:new)
        end
      end

      context 'when the file is an invalid file type' do
        let(:invalid_file) { fixture_file_upload('myott/mycommodities_files/invalid_file_type.xls', 'application/vnd.ms-excel') }

        before do
          post :create, params: { myott_commodity_upload_form: { file: invalid_file } }
        end

        it 'adds a validation error to the form' do
          expect(assigns(:upload_form).errors[:file]).to include('Selected file must be in a CSV or XLSX format')
        end

        it 'renders the new template again' do
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'GET #download' do
    let(:file_data) do
      {
        body: 'file content',
        filename: 'commodity_watch_list_changes_2025-12-05.xlsx',
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      }
    end
    let(:user_id_token) { 'test-token' }

    it_behaves_like 'a protected myott page', :download

    context 'when current_user is valid' do
      before do
        stub_authenticated_user(user)
        stub_get_subscription('my_commodities', subscription)
        allow(controller).to receive(:user_id_token).and_return(user_id_token)
        allow(TariffChanges::TariffChange).to receive(:download_file).and_return(file_data)
        get :download
      end

      it { is_expected.to respond_with(:success) }

      it 'sets Content-Disposition header', :aggregate_failures do
        expect(response.headers['Content-Disposition']).to include('attachment')
        expect(response.headers['Content-Disposition']).to include('commodity_watch_list_changes_2025-12-05.xlsx')
      end

      it 'sets Content-Type header' do
        expect(response.headers['Content-Type']).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      end

      it 'sets Cache-Control header' do
        expect(response.headers['Cache-Control']).to eq('no-cache')
      end

      it 'calls TariffChange.download_file with correct params' do
        expect(TariffChanges::TariffChange).to have_received(:download_file).with(
          user_id_token,
          hash_including(as_of: anything),
        )
      end

      it 'returns file body' do
        expect(response.body).to eq(file_data[:body])
      end
    end

    context 'when user does not have a my commodities subscription' do
      before do
        stub_authenticated_user(user)
        stub_get_subscription('my_commodities', nil)
        get :download
      end

      it { is_expected.to redirect_to(new_myott_mycommodity_path) }
    end
  end
end
