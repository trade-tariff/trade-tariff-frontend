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

  describe '#measures_heading' do
    shared_examples_for 'a measure heading' do |anchor, expected_text|
      subject { helper.measures_heading(anchor:) }

      it { is_expected.to eq(expected_text) }
    end

    it_behaves_like 'a measure heading', 'import', 'Importing into the UK' do
      include_context 'with UK service'
    end

    it_behaves_like 'a measure heading', 'export', 'Exporting from the UK' do
      include_context 'with UK service'
    end

    it_behaves_like 'a measure heading', 'import', 'Importing into Northern Ireland' do
      include_context 'with XI service'
    end

    it_behaves_like 'a measure heading', 'export', 'Exporting from Northern Ireland' do
      include_context 'with XI service'
    end
  end

  describe '#goods_nomenclature_title' do
    let(:commodity) { build(:commodity, description_plain: 'Live horses, asses, mules and hinnies') }

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
    subject(:link) { helper.switch_service_link }

    before { allow(request).to receive(:path).and_return '/some_path' }

    context 'when the selected service choice is uk' do
      include_context 'with UK service'

      it 'returns the link to the XI service' do
        expect(link).to have_link 'Northern Ireland Online Tariff', href: '/xi/some_path'
      end
    end

    context 'when the selected service choice is xi' do
      include_context 'with XI service'

      it 'returns the link to the current UK service' do
        expect(link).to have_link 'UK Integrated Online Tariff', href: '/some_path'
      end
    end

    context 'with url parts including service name' do
      subject(:link) { helper.switch_service_link }

      before { allow(request).to receive(:path).and_return '/some_path/uk-part' }

      it 'switches correctly' do
        expect(link).to have_link 'Northern Ireland Online Tariff',
                                  href: '/xi/some_path/uk-part'
      end
    end
  end

  describe '#switch_service_button' do
    subject { helper.switch_service_button }

    before { allow(request).to receive(:path).and_return '/some_path' }

    context 'with UK service' do
      include_context 'with UK service'

      it { is_expected.to have_css 'span.switch-service-control span.arrow', text: nil }
      it { is_expected.to have_css 'span.switch-service-control a.govuk-link--no-underline' }
      it { is_expected.to have_link 'Switch to the Northern Ireland Online Tariff', href: '/xi/some_path' }
    end

    context 'with XI' do
      include_context 'with XI service'

      it { is_expected.to have_css 'span.switch-service-control span.arrow', text: nil }
      it { is_expected.to have_css 'span.switch-service-control a.govuk-link--no-underline' }
      it { is_expected.to have_link 'Switch to the UK Integrated Online Tariff', href: '/some_path' }
    end

    context 'with service part later in URL' do
      subject { helper.switch_service_button }

      before { allow(request).to receive(:path).and_return '/some_path/uk-part' }

      include_context 'with UK service'

      it { is_expected.to have_link 'Switch to the Northern Ireland Online Tariff', href: '/xi/some_path/uk-part' }
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

  describe '#service_region' do
    subject { service_region }

    context 'with UK service' do
      include_context 'with UK service'

      it { is_expected.to eql 'the UK' }
    end

    context 'with XI service' do
      include_context 'with XI service'

      it { is_expected.to eql 'Northern Ireland' }
    end
  end

  describe '.replace_service_tags' do
    subject { replace_service_tags content }

    context 'with UK service' do
      include_context 'with UK service'

      context 'without tags' do
        let(:content) { 'this is some sample content' }

        it { is_expected.to eql 'this is some sample content' }
      end

      context 'with SERVICE_NAME tag' do
        let(:content) { 'You are on the [[SERVICE_NAME]]' }

        it { is_expected.to eql 'You are on the UK Integrated Online Tariff' }
      end

      context 'with SERVICE_PATH tag' do
        let(:content) { '<a href="[[SERVICE_PATH]]/browse">Browse</a>' }

        it { is_expected.to eql '<a href="/browse">Browse</a>' }
      end

      context 'with SERVICE_REGION' do
        let(:content) { 'within [[SERVICE_REGION]]' }

        it { is_expected.to eql 'within the UK' }
      end

      context 'with multiple tags' do
        let :content do
          <<~END_OF_CONTENT
            [[SERVICE_NAME]]
            * [Find commodity]([[SERVICE_PATH]]/find_commodity)
            * [Browse]([[SERVICE_PATH]]/browse)
          END_OF_CONTENT
        end

        let :expected do
          <<~END_OF_EXPECTED
            UK Integrated Online Tariff
            * [Find commodity](/find_commodity)
            * [Browse](/browse)
          END_OF_EXPECTED
        end

        it { is_expected.to eql expected }
      end
    end

    context 'with XI service' do
      include_context 'with XI service'

      context 'without tags' do
        let(:content) { 'this is some sample content' }

        it { is_expected.to eql 'this is some sample content' }
      end

      context 'with SERVICE_NAME tag' do
        let(:content) { 'You are on the [[SERVICE_NAME]]' }

        it { is_expected.to eql 'You are on the Northern Ireland Online Tariff' }
      end

      context 'with SERVICE_PATH tag' do
        let(:content) { '<a href="[[SERVICE_PATH]]/browse">Browse</a>' }

        it { is_expected.to eql '<a href="/xi/browse">Browse</a>' }
      end

      context 'with SERVICE_REGION' do
        let(:content) { 'within [[SERVICE_REGION]]' }

        it { is_expected.to eql 'within Northern Ireland' }
      end

      context 'with multiple tags' do
        let :content do
          <<~END_OF_CONTENT
            [[SERVICE_NAME]]
            * [Find commodity]([[SERVICE_PATH]]/find_commodity)
            * [Browse]([[SERVICE_PATH]]/browse)
          END_OF_CONTENT
        end

        let :expected do
          <<~END_OF_EXPECTED
            Northern Ireland Online Tariff
            * [Find commodity](/xi/find_commodity)
            * [Browse](/xi/browse)
          END_OF_EXPECTED
        end

        it { is_expected.to eql expected }
      end
    end

    context 'with LOCALE_PATH' do
      let(:content) { '[Browse]([[LOCALE_PATH]]/browse)' }

      context 'with English locale' do
        it { is_expected.to eql '[Browse](/browse)' }
      end

      context 'with Cymru locale' do
        include_context 'with Cymru locale'

        it { is_expected.to eql '[Browse](/cy/browse)' }
      end
    end

    context 'with PREFIX_PATH' do
      let(:content) { '[Browse]([[PREFIX_PATH]]/browse)' }

      context 'with UK service and default locale' do
        include_context 'with UK service'

        it { is_expected.to eql '[Browse](/browse)' }
      end

      context 'with UK service and Cymru locale' do
        include_context 'with UK service'
        include_context 'with Cymru locale'

        it { is_expected.to eql '[Browse](/cy/browse)' }
      end

      context 'with XI service and default locale' do
        include_context 'with XI service'

        it { is_expected.to eql '[Browse](/xi/browse)' }
      end

      context 'with XI service and Cymru locale' do
        include_context 'with XI service'
        include_context 'with Cymru locale'

        it { is_expected.to eql '[Browse](/xi/cy/browse)' }
      end
    end
  end

  describe '#import_export_date_title' do
    subject(:import_export_date_title) { helper.import_export_date_title }

    context 'when the selected service choice is xi' do
      include_context 'with XI service'

      it { is_expected.to eq('Northern Ireland Online Tariff - When will your goods be traded - GOV.UK') }
    end

    context 'when the selected service choice is nil' do
      include_context 'with default service'

      it { is_expected.to eq('UK Integrated Online Tariff - When will your goods be traded - GOV.UK') }
    end
  end

  describe '#trading_partner_title' do
    subject(:trading_partner_title) { helper.trading_partner_title }

    context 'when the selected service choice is xi' do
      include_context 'with XI service'

      it { is_expected.to eq('Northern Ireland Online Tariff - Set country filter - GOV.UK') }
    end

    context 'when the selected service choice is nil' do
      include_context 'with default service'

      it { is_expected.to eq('UK Integrated Online Tariff - Set country filter - GOV.UK') }
    end
  end

  describe '#insert_service_links' do
    subject(:insert_service_links) { helper.insert_service_links(html) }

    let(:html) do
      helper.govspeak(
        'fish and crustaceans of heading [0301](headings/0301), [0306](/xi/headings/0306), [0221](https://google.com), [0220](http://gov.uk',
      )
    end

    context 'when the XI service choice is selected' do
      include_context 'with XI service'

      it { is_expected.to eq("<p>fish and crustaceans of heading <a href=\"/xi/headings/0301\">0301</a>, <a href=\"/xi/headings/0306\">0306</a>, <a rel=\"external\" href=\"https://google.com\">0221</a>, [0220](http://gov.uk</p>\n") }
    end

    context 'when the UK service choice is selected' do
      include_context 'with UK service'

      it { is_expected.to eq(html) }
    end

    context 'when the default service choice is selected' do
      include_context 'with default service'

      it { is_expected.to eq(html) }
    end

    context 'when the input html is nil' do
      let(:html) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the input html is an empty string' do
      let(:html) { '' }

      it { is_expected.to eq('') }
    end
  end

  describe '#enquiry_form_title' do
    let(:field) { 'query' }

    before do
      allow(helper).to receive(:service_name).and_return('UK Integrated Online Tariff')
    end

    context 'when there is a flash error' do
      it 'includes the error title prefix' do
        helper.flash.now[:error] = 'Something went wrong'

        expect(helper.enquiry_form_title(field))
          .to eq('Error: Enquiry Form | How can we help?')
      end
    end

    context 'when there is no flash error' do
      it 'does not include the error title prefix' do
        helper.flash.now[:error] = nil

        expect(helper.enquiry_form_title(field))
          .to eq('Enquiry Form | How can we help?')
      end
    end
  end
end
