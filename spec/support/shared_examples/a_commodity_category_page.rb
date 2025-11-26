RSpec.shared_examples 'a commodity category page' do |action, category|
  subject { response }

  let(:page) { '2' }
  let(:per_page) { '20' }
  let(:user_id_token) { 'valid-jwt-token' }

  before do
    allow(controller).to receive_messages(get_subscription: subscription, user_id_token: user_id_token)

    targets = build_list(:subscription_target, 3)
    allow(targets).to receive(:total_count).and_return(3)

    expected_params = {
      filter: { active_commodities_type: category },
      page: page,
      per_page: per_page,
    }

    allow(SubscriptionTarget).to receive(:all)
      .with(subscription.resource_id, user_id_token, expected_params)
      .and_return(targets)

    get action, params: { page: page, per_page: per_page }
  end

  it 'assigns commodities as SubscriptionTarget instances' do
    expect(assigns(:commodities)).to all(be_a(SubscriptionTarget))
  end

  it 'assigns the correct number of commodities' do
    expect(assigns(:commodities).size).to eq(3)
  end
end
