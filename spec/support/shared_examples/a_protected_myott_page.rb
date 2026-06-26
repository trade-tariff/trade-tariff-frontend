RSpec.shared_examples 'a protected myott page' do |action|
  context 'when current_user is not valid' do
    before do
      stub_unauthenticated_user
      get action
    end

    it { is_expected.to redirect_to myott_start_path }
  end
end
