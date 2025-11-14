RSpec.shared_examples 'a commodity category page' do |action, category|
  subject { response }

  before do
    allow(controller).to receive(:get_subscription).and_return(subscription)

    targets = build_list(:subscription_target, 3)

    targets.define_singleton_method(:total_count) { 3 }

    allow(SubscriptionTarget).to receive(:all)
   .with(subscription.resource_id, category, page: '2', per_page: '20')
   .and_return(targets)

    get action, params: { page: '2', per_page: '20' }
  end

  it { is_expected.to render_template(:list) }

  it 'assigns the category' do
    expect(assigns(:category)).to eq(category.capitalize)
  end

  it 'assigns commodities as SubscriptionTarget instances' do
    expect(assigns(:commodities)).to all(be_a(SubscriptionTarget))
  end

  it 'assigns the correct number of commodities' do
    expect(assigns(:commodities).size).to eq(3)
  end

  it 'assigns the total commodities count' do
    expect(assigns(:total_commodities_count)).to eq(3)
  end
end
