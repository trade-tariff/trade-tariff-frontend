RSpec.describe 'FeatureOptIns', type: :request do
  describe 'POST /feature_opt_ins' do
    context 'with a flag not in MANAGEABLE_FEATURES' do
      it 'returns 403' do
        post '/feature_opt_ins', params: { feature: 'green_lanes' }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /feature_opt_ins/:id' do
    context 'with a flag not in MANAGEABLE_FEATURES' do
      it 'returns 403' do
        delete '/feature_opt_ins/green_lanes'
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
