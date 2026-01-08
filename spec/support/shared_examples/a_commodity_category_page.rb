RSpec.shared_examples 'a commodity category page' do |action|
  subject { response }

  let(:page) { '2' }
  let(:per_page) { '20' }
  let(:user_id_token) { 'valid-jwt-token' }

  it_behaves_like 'a protected myott page', action

  before do
    allow(controller).to receive_messages(get_subscription: subscription, user_id_token: user_id_token)

    targets = build_list(:subscription_target, 3)
    allow(targets).to receive(:count).and_return(3)

    expected_params = {
      filter: { active_commodities_type: action.to_s },
      page: page,
      per_page: per_page,
    }

    allow(SubscriptionTarget).to receive(:all)
      .with(subscription.resource_id, user_id_token, expected_params)
      .and_return(targets)

    get action, params: { page: page, per_page: per_page }
  end

  it 'assigns targets as SubscriptionTarget instances' do
    expect(assigns(:targets)).to all(be_a(SubscriptionTarget))
  end

  it 'assigns the correct number of targets' do
    expect(assigns(:targets).count).to eq(3)
  end
end
