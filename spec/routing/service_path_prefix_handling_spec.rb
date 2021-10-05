require 'spec_helper'

RSpec.describe RoutingFilter::ServicePathPrefixHandler, type: :routing do
  let(:path) { "#{prefix}/commodities/0101300000" }

  after do
    Thread.current[:service_choice] = nil
  end

  describe 'matching routes' do
    context 'when the service choice prefix is xi' do
      let(:prefix) { '/xi' }

      it 'sets the request params service choice to the xi backend' do
        expect(get: path).to route_to(
          controller: 'commodities',
          action: 'show',
          id: '0101300000',
        )
        expect(Thread.current[:service_choice]).to eq('xi')
      end
    end

    context 'when the service choice prefix is not present' do
      let(:prefix) { nil }

      it 'does not specify the service backend' do
        expect(get: path).to route_to(
          controller: 'commodities',
          action: 'show',
          id: '0101300000',
        )
        expect(Thread.current[:service_choice]).to be_nil
      end
    end

    context 'when the service choice prefix is the same as the default' do
      let(:prefix) { '/uk' }

      it 'does not set the request params service choice' do
        expect(get: path).to route_to(
          controller: 'commodities',
          action: 'show',
          id: '0101300000',
        )
        expect(Thread.current[:service_choice]).to eq('uk')
      end
    end

    context 'when the service choice prefix is set to an unsupported service choice' do
      let(:prefix) { '/xixi' }

      it 'routes to a not_found action in the errors controller' do
        expect(get: path).to route_to(
          controller: 'errors',
          action: 'not_found',
          path: 'xixi/commodities/0101300000',
        )
        expect(Thread.current[:service_choice]).to eq(nil)
      end
    end

    context 'when the service choice prefix is the only thing in the path' do
      let(:path) { prefix.to_s }
      let(:prefix) { '/xi' }

      it 'routes to a not_found action in the errors controller' do
        expect(get: path).not_to be_routable
      end
    end
  end

  describe 'path generation' do
    let(:commodity_id) { '0101210000' }
    let(:service_default) { 'uk' }

    before do
      TradeTariffFrontend::ServiceChooser.service_choice = choice
    end

    context 'when the service choice is not the default' do
      let(:choice) { 'xi' }

      it 'prepends the choice to the url' do
        result = commodity_url(
          id: commodity_id,
          currency: 'EUR',
        )

        expect(result).to eq('http://test.host/xi/commodities/0101210000?currency=EUR')
      end

      it 'prepends the choice to the path' do
        result = commodity_path(
          id: commodity_id,
          currency: 'EUR',
        )

        expect(result).to eq('/xi/commodities/0101210000?currency=EUR')
      end
    end

    context 'when the service choice is the default' do
      let(:choice) { 'uk' }

      it 'does not prepend the choice to the url' do
        result = commodity_path(
          id: commodity_id,
          currency: 'EUR',
        )

        expect(result).to eq('/commodities/0101210000?currency=EUR')
      end

      it 'does not prepend the choice to the path' do
        result = commodity_path(
          id: commodity_id,
          currency: 'EUR',
        )

        expect(result).to eq('/commodities/0101210000?currency=EUR')
      end
    end

    context 'when the path helper is generated using a custom url helper' do
      let(:choice) { 'xi' }

      it 'prepends the choice to the path' do
        result = a_z_index_path(letter: 'a')

        expect(result).to eq('/xi/a-z-index/a')
      end
    end

    context 'when the url helper is generated with a router :as helper' do
      let(:choice) { 'xi' }

      it 'prepends the choice to the path' do
        result = sections_path

        expect(result).to eq('/xi/sections')
      end

      it 'prepends the choice to the url' do
        result = sections_url

        expect(result).to eq('http://test.host/xi/sections')
      end
    end
  end
end
