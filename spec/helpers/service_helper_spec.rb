require 'spec_helper'

describe ServiceHelper, type: :helper do
  before do
    allow(TradeTariffFrontend::ServiceChooser).to receive(:service_choice).and_return(choice)
  end

  describe '.default_title' do
    context 'when the selected service choice is xi' do
      let(:choice) { 'xi' }

      it 'returns the title for the current service choice' do
        expect(helper.default_title).to eq('The Northern Ireland (EU) Tariff: Look up commodity codes, import duty, VAT and controls - GOV.UK')
      end
    end

    context 'when the selected service choice is nil' do
      let(:choice) { nil }

      it 'returns the title for the current service choice' do
        expect(helper.default_title).to eq('The Online Trade Tariff: Look up commodity codes, import duty, VAT and controls - GOV.UK')
      end
    end
  end

  describe '.goods_nomenclature_title' do
    let(:goods_nomenclature) { double(to_s: 'Live horses, asses, mules and hinnies') }

    context 'when the selected service choice is xi' do
      let(:choice) { 'xi' }

      it 'returns the correct title for the current goods nomenclature' do
        expect(helper.goods_nomenclature_title(goods_nomenclature)).to eq('Live horses, asses, mules and hinnies - The Northern Ireland (EU) Tariff - GOV.UK')
      end
    end

    context 'when the selected service choice is nil' do
      let(:choice) { nil }

      it 'returns the correct title for the current goods nomenclature' do
        expect(helper.goods_nomenclature_title(goods_nomenclature)).to eq('Live horses, asses, mules and hinnies - The Online Trade Tariff - GOV.UK')
      end
    end
  end

  describe '.commodity_title' do
    let(:commodity) { double(to_s: 'Pure-bred breeding animals', code: '0101300000') }

    context 'when the selected service choice is xi' do
      let(:choice) { 'xi' }

      it 'returns the correct title for the current goods nomenclature' do
        expect(helper.commodity_title(commodity)).to eq('Commodity code 0101300000: Pure-bred breeding animals - The Northern Ireland (EU) Tariff - GOV.UK')
      end
    end

    context 'when the selected service choice is nil' do
      let(:choice) { nil }

      it 'returns the correct title for the current goods nomenclature' do
        expect(helper.commodity_title(commodity)).to eq('Commodity code 0101300000: Pure-bred breeding animals - The Online Trade Tariff - GOV.UK')
      end
    end
  end

  describe '.trade_tariff_heading' do
    context 'when the selected service choice is uk-old' do
      let(:choice) { 'uk-old' }

      it 'returns The Online Trade Tariff' do
        expect(trade_tariff_heading).to eq('The Online Trade Tariff')
      end
    end

    context 'when the selected service choice is uk' do
      let(:choice) { 'uk' }

      it 'returns The Online Trade Tariff' do
        expect(trade_tariff_heading).to eq('The Online Trade Tariff')
      end
    end

    context 'when the selected service choice is xi' do
      let(:choice) { 'xi' }

      it 'returns The Northern Ireland (EU) Tariff' do
        expect(trade_tariff_heading).to eq('The Northern Ireland (EU) Tariff')
      end
    end
  end

  describe '.switch_service_link' do
    let(:request) { double('request', filtered_path: path) }

    before do
      allow(helper).to receive(:request).and_return(request)
    end

    context 'when the selected service choice is uk-old' do
      let(:path) { '/sections/1' }
      let(:choice) { 'uk-old' }

      it 'returns the link to the XI service' do
        expect(switch_service_link).to eq(link_to('Northern Ireland (EU) Tariff', '/xi/sections/1'))
      end
    end

    context 'when the selected service choice is uk' do
      let(:path) { '/uk/sections/1' }
      let(:choice) { 'uk' }

      it 'returns the link to the XI service' do
        expect(switch_service_link).to eq(link_to('Northern Ireland (EU) Tariff', '/xi/sections/1'))
      end
    end

    context 'when the selected service choice is xi' do
      let(:path) { '/xi/sections/1' }
      let(:choice) { 'xi' }

      it 'returns the link to the current UK service' do
        expect(switch_service_link).to eq(link_to('Online Tariff', '/sections/1'))
      end
    end
  end

  describe '.service_switch_banner' do
    let(:request) { double('request', filtered_path: '/xi/sections/1') }
    let(:choice) { 'xi' }
    let(:service_choosing_enabled) { true }

    before do
      allow(TradeTariffFrontend::ServiceChooser).to receive(:enabled?).and_return(service_choosing_enabled)
    end

    context 'when on xi sections page' do
      let(:request) { double('request', filtered_path: '/xi/sections') }

      it 'returns the full banner that allows users to toggle between the services' do
        expect(service_switch_banner).to include(t("service_banner.big.#{choice}", link: switch_service_link))
      end
    end

    context 'when not on sections page' do
      it 'returns the subtle banner that allows users to toggle between the services' do
        expect(service_switch_banner).to include(t('service_banner.small', link: switch_service_link))
      end
    end

    context 'when service choosing is disabled' do
      let(:service_choosing_enabled) { false }

      it 'returns nil' do
        expect(service_switch_banner).to be_nil
      end
    end
  end
end
