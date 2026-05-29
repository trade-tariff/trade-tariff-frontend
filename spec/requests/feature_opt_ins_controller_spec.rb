RSpec.describe FeatureOptInsController, type: :request do
  let(:anonymous_uuid) { 'test-uuid-123' }

  before do
    cookies[:flipper_anonymous_id] = anonymous_uuid
    stub_const('FeatureOptInsController::MANAGEABLE_FEATURES', %i[test_flag])
  end

  describe 'POST /feature_opt_ins' do
    context 'with a known opt-in-able flag' do
      it 'enables the actor for the flag and redirects' do
        post feature_opt_ins_path, params: { feature: 'test_flag' }

        actor = Flipper::AnonymousActor.new(anonymous_uuid)
        expect(Flipper.enabled?(:test_flag, actor)).to be true
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with an unknown flag' do
      it 'returns 403' do
        post feature_opt_ins_path, params: { feature: 'nonexistent_flag' }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /feature_opt_ins' do
    context 'with a known opt-in-able flag' do
      before do
        actor = Flipper::AnonymousActor.new(anonymous_uuid)
        Flipper.enable_actor(:test_flag, actor)
      end

      it 'disables the actor for the flag and redirects' do
        delete feature_opt_in_path('test_flag')

        actor = Flipper::AnonymousActor.new(anonymous_uuid)
        expect(Flipper.enabled?(:test_flag, actor)).to be false
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
