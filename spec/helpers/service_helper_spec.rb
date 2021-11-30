require 'spec_helper'

RSpec.describe ServiceHelper, type: :helper do
  describe '.default_title' do
    context 'when the selected service choice is xi' do
      include_context 'with XI service'

      it 'returns the title for the current service choice' do
        expect(helper.default_title).to eq('Northern Ireland Online Tariff: Look up commodity codes, duty and VAT rates - GOV.UK')
      end
    end

    context 'when the selected service choice is nil' do
      include_context 'with default service'

      it 'returns the title for the current service choice' do
        expect(helper.default_title).to eq('UK Integrated Online Tariff: Look up commodity codes, duty and VAT rates - GOV.UK')
      end
    end
  end

  describe '#heading_for' do
    subject { helper.heading_for(section: section, chapter: chapter, heading: heading, commodity: commodity) }

    let(:section) { instance_double('Section', page_heading: 'Section AAA') }
    let(:chapter) { instance_double('Chapter', page_heading: 'Chapter BBB') }
    let(:heading) { instance_double('Heading', page_heading: 'Heading CCC') }
    let(:commodity) { instance_double('Commodity', page_heading: 'Commodity EEE') }

    context 'when in Commodity page' do
      it { is_expected.to eq('Commodity EEE') }
    end

    context 'when in Heading page' do
      let(:commodity) { nil }

      it { is_expected.to eq('Heading CCC') }
    end

    context 'when in Chapter page' do
      let(:heading) { nil }
      let(:commodity) { nil }

      it { is_expected.to eq('Chapter BBB') }
    end

    context 'when in Section page' do
      let(:heading) { nil }
      let(:commodity) { nil }
      let(:chapter) { nil }

      it { is_expected.to eq('Section AAA') }
    end
  end

  describe '#goods_nomenclature_title' do
    let(:commodity) { build(:commodity, formatted_description: 'Live horses, asses, mules and hinnies') }

    context 'when the selected service choice is xi' do
      include_context 'with XI service'

      it 'returns the correct title for the current goods nomenclature' do
        expect(helper.goods_nomenclature_title(commodity)).to eq('Live horses, asses, mules and hinnies - Northern Ireland Online Tariff - GOV.UK')
      end
    end

    context 'when the selected service choice is nil' do
      include_context 'with default service'

      it 'returns the correct title for the current goods nomenclature' do
        expect(helper.goods_nomenclature_title(commodity)).to eq('Live horses, asses, mules and hinnies - UK Integrated Online Tariff - GOV.UK')
      end
    end
  end

  describe '#commodity_title' do
    let(:commodity) { build(:commodity, formatted_description: 'Pure-bred breeding animals', goods_nomenclature_item_id: '0101300000') }

    context 'when the selected service choice is xi' do
      include_context 'with XI service'

      it 'returns the correct title for the current goods nomenclature' do
        expect(helper.commodity_title(commodity)).to eq('Commodity code 0101300000: Pure-bred breeding animals - Northern Ireland Online Tariff - GOV.UK')
      end
    end

    context 'when the selected service choice is nil' do
      include_context 'with default service'

      it 'returns the correct title for the current goods nomenclature' do
        expect(helper.commodity_title(commodity)).to eq('Commodity code 0101300000: Pure-bred breeding animals - UK Integrated Online Tariff - GOV.UK')
      end
    end
  end

  describe '#trade_tariff_heading' do
    context 'when the selected service choice is uk' do
      include_context 'with UK service'

      it 'returns UK Integrated Online Tariff' do
        expect(trade_tariff_heading).to eq('UK Integrated Online Tariff')
      end
    end

    context 'when the selected service choice is xi' do
      include_context 'with XI service'

      it 'returns Northern Ireland Online Tariff' do
        expect(trade_tariff_heading).to eq('Northern Ireland Online Tariff')
      end
    end
  end

  describe '#switch_service_link' do
    before do
      helper.request.path = path
    end

    context 'when the selected service choice is uk' do
      include_context 'with UK service'

      let(:path) { '/uk/sections/1' }

      it 'returns the link to the XI service' do
        expect(helper.switch_service_link).to eq(link_to('Northern Ireland Online Tariff', '/xi/sections/1'))
      end
    end

    context 'when the selected service choice is xi' do
      include_context 'with XI service'

      let(:path) { '/xi/sections/1' }

      it 'returns the link to the current UK service' do
        expect(helper.switch_service_link).to eq(link_to('UK Integrated Online Tariff', '/sections/1'))
      end
    end
  end

  describe '#switch_banner_copy' do
    before do
      helper.request.path = path
      assign(:enable_service_switch_banner_in_action, true)
    end

    include_context 'with XI service'

    context 'when on sections page' do
      let(:path) { '/xi/sections' }

      it 'returns the full banner that allows users to toggle between the services' do
        expect(helper.switch_banner_copy).to include(t('service_banner.big.xi', link: helper.switch_service_link))
      end
    end

    context 'when not on sections page' do
      let(:path) { '/xi/foo' }

      it 'returns the subtle banner that allows users to toggle between the services' do
        expect(helper.switch_banner_copy).to include(t('service_banner.small', link: helper.switch_service_link))
      end
    end
  end

  describe '#service_choice' do
    context 'when there is a service choice set' do
      include_context 'with XI service'

      it { expect(helper.service_choice).to eq('xi') }
    end

    context 'when the selected service choice is nil' do
      include_context 'with default service'

      it { expect(helper.service_choice).to eq('uk') }
    end
  end

  describe '#import_destination' do
    context 'when there is a service choice is xi' do
      include_context 'with XI service'

      it { expect(helper.import_destination).to eq('Northern Ireland') }
    end

    context 'when the selected service choice is uk' do
      include_context 'with UK service'

      it { expect(helper.import_destination).to eq('United Kingdom') }
    end
  end

  describe '#service_name' do
    subject { service_name }

    context 'with UK service' do
      include_context 'with UK service'

      it { is_expected.to eql 'UK Integrated Online Tariff' }
    end

    context 'with XI service' do
      include_context 'with XI service'

      it { is_expected.to eql 'Northern Ireland Online Tariff' }
    end
  end

  describe '#region_name' do
    subject { region_name }

    context 'with UK service' do
      include_context 'with UK service'

      it { is_expected.to eql 'the UK' }
    end

    context 'with XI service' do
      include_context 'with XI service'

      it { is_expected.to eql 'Northern Ireland' }
    end
  end
end
