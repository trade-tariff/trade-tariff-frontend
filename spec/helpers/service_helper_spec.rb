require 'spec_helper'

describe ServiceHelper, type: :helper do
  before do
    allow(TradeTariffFrontend::ServiceChooser).to receive(:service_choice).and_return(choice)
  end

  let(:choice) { 'xi' }

  describe '.default_title' do
    context 'when the selected service choice is xi' do
      let(:choice) { 'xi' }

      it 'returns the title for the current service choice' do
        expect(helper.default_title).to eq('Northern Ireland Online Tariff: look up commodity codes, duty and VAT rates - GOV.UK')
      end
    end

    context 'when the selected service choice is nil' do
      let(:choice) { nil }

      it 'returns the title for the current service choice' do
        expect(helper.default_title).to eq('UK Integrated Online Tariff: look up commodity codes, duty and VAT rates - GOV.UK')
      end
    end
  end

  describe '.goods_nomenclature_title' do
    let(:commodity) { build(:commodity, formatted_description: 'Live horses, asses, mules and hinnies') }

    context 'when the selected service choice is xi' do
      let(:choice) { 'xi' }

      it 'returns the correct title for the current goods nomenclature' do
        expect(helper.goods_nomenclature_title(commodity)).to eq('Live horses, asses, mules and hinnies - Northern Ireland Online Tariff - GOV.UK')
      end
    end

    context 'when the selected service choice is nil' do
      let(:choice) { nil }

      it 'returns the correct title for the current goods nomenclature' do
        expect(helper.goods_nomenclature_title(commodity)).to eq('Live horses, asses, mules and hinnies - UK Integrated Online Tariff - GOV.UK')
      end
    end
  end

  describe '.commodity_title' do
    let(:commodity) { build(:commodity, formatted_description: 'Pure-bred breeding animals', goods_nomenclature_item_id: '0101300000') }

    context 'when the selected service choice is xi' do
      let(:choice) { 'xi' }

      it 'returns the correct title for the current goods nomenclature' do
        expect(helper.commodity_title(commodity)).to eq('Commodity code 0101300000: Pure-bred breeding animals - Northern Ireland Online Tariff - GOV.UK')
      end
    end

    context 'when the selected service choice is nil' do
      let(:choice) { nil }

      it 'returns the correct title for the current goods nomenclature' do
        expect(helper.commodity_title(commodity)).to eq('Commodity code 0101300000: Pure-bred breeding animals - UK Integrated Online Tariff - GOV.UK')
      end
    end
  end

  describe '.trade_tariff_heading' do
    context 'when the selected service choice is uk' do
      let(:choice) { 'uk' }

      it 'returns UK Integrated Online Tariff' do
        expect(trade_tariff_heading).to eq('UK Integrated Online Tariff')
      end
    end

    context 'when the selected service choice is xi' do
      let(:choice) { 'xi' }

      it 'returns Northern Ireland Online Tariff' do
        expect(trade_tariff_heading).to eq('Northern Ireland Online Tariff')
      end
    end
  end

  describe '.switch_service_link' do
    before do
      helper.request.path = path
    end

    context 'when the selected service choice is uk' do
      let(:path) { '/uk/sections/1' }
      let(:choice) { 'uk' }

      it 'returns the link to the XI service' do
        expect(helper.switch_service_link).to eq(link_to('Northern Ireland Online Tariff', '/xi/sections/1'))
      end
    end

    context 'when the selected service choice is xi' do
      let(:path) { '/xi/sections/1' }
      let(:choice) { 'xi' }

      it 'returns the link to the current UK service' do
        expect(helper.switch_service_link).to eq(link_to('UK Integrated Online Tariff', '/sections/1'))
      end
    end
  end

  describe '.service_switch_banner' do
    before do
      helper.request.path = path
      assign(:enable_service_switch_banner_in_action, true)
    end

    context 'when on xi sections page' do
      let(:path) { '/xi/sections' }

      it 'returns the full banner that allows users to toggle between the services' do
        expect(helper.service_switch_banner).to include(t("service_banner.big.#{choice}", link: helper.switch_service_link))
      end
    end

    context 'when not on sections page' do
      let(:path) { '/xi/foo' }

      it 'returns the subtle banner that allows users to toggle between the services' do
        expect(helper.service_switch_banner).to include(t('service_banner.small', link: helper.switch_service_link))
      end
    end

    context 'when service switching is disabled for the action' do
      before do
        assign(:enable_service_switch_banner_in_action, false)
      end

      let(:path) { '/xi/sections' }

      it { expect(helper.service_switch_banner).to be_nil }
    end
  end

  describe '.service_choice' do
    context 'when there is a service choice set' do
      let(:choice) { 'xi' }

      it 'returns xi' do
        expect(helper.service_choice).to eq(choice)
      end
    end

    context 'when the selected service choice is nil' do
      let(:choice) { nil }

      it 'returns the default service which is uk' do
        expect(helper.service_choice).to eq('uk')
      end
    end
  end

  describe '.import_destination' do
    context 'when there is a service choice is xi' do
      let(:choice) { 'xi' }

      it 'returns Northern Ireland' do
        expect(helper.import_destination).to eq('Northern Ireland')
      end
    end

    context 'when the selected service choice is uk' do
      let(:choice) { 'uk' }

      it 'returns United Kingdom' do
        expect(helper.import_destination).to eq('United Kingdom')
      end
    end
  end
end
