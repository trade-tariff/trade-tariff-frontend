require 'spec_helper'

RSpec.describe SectionsController, type: :controller do
  describe 'GET #index', vcr: { cassette_name: 'sections#index' } do
    include CrawlerCommons

    context 'with old sections page' do
      before do
        allow(TradeTariffFrontend).to receive(:updated_navigation?).and_return false
      end

      context 'with non historical request' do
        before { get :index }

        it { is_expected.to respond_with(:success) }
        it { expect(assigns(:sections)).to be_a(Array) }
        it { should_not_include_robots_tag! }
      end

      context 'with historical request' do
        before do
          VCR.use_cassette 'sections#historical_index' do
            historical_request :index
          end
        end

        it { should_include_robots_tag! }
      end
    end

    context 'with separated browse and find pages' do
      subject { get :index }

      it { is_expected.to redirect_to find_commodity_path }
    end
  end

  describe 'GET to #show', vcr: { cassette_name: 'sections#show' } do
    include CrawlerCommons

    let!(:section) { build :section }

    context 'with non historical' do
      before { get :show, params: { id: section.position } }

      it { is_expected.to respond_with(:success) }
      it { expect(assigns(:section)).to be_a(Section) }
      it { expect(assigns(:chapters)).to be_a(Array) }
      it { should_not_include_robots_tag! }
    end

    context 'with historical' do
      before do
        VCR.use_cassette 'sections#historical_show' do
          historical_request(:show, id: section.position)
        end
      end

      it { should_include_robots_tag! }
    end
  end
end
