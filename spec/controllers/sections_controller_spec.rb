require 'spec_helper'

RSpec.describe SectionsController, 'GET to #index', type: :controller, vcr: { cassette_name: 'sections#index' } do
  include CrawlerCommons

  context 'non historical' do
    before { get :index }

    it { is_expected.to respond_with(:success) }
    it { expect(assigns(:sections)).to be_a(Array) }
    it { should_not_include_robots_tag! }
  end

  context 'historical request' do
    before do
      VCR.use_cassette 'sections#historical_index' do
        historical_request :index
      end
    end

    it { should_include_robots_tag! }
  end
end

RSpec.describe SectionsController, 'GET to #show', type: :controller do
  include CrawlerCommons

  context 'with existing section id provided', vcr: { cassette_name: 'sections#show' } do
    let!(:section) { build :section }

    context 'non historical' do
      before { get :show, params: { id: section.position } }

      it { is_expected.to respond_with(:success) }
      it { expect(assigns(:section)).to be_a(Section) }
      it { expect(assigns(:chapters)).to be_a(Array) }
      it { should_not_include_robots_tag! }
    end

    context 'historical' do
      before do
        VCR.use_cassette 'sections#historical_show' do
          historical_request(:show, id: section.position)
        end
      end

      it { should_include_robots_tag! }
    end
  end
end
