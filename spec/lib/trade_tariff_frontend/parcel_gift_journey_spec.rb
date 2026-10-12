require 'spec_helper'

RSpec.describe TradeTariffFrontend::ParcelGiftJourney do
  subject(:journey) { described_class.new(config, service_names: %w[uk xi]) }

  let(:config) { YAML.safe_load_file(Rails.root.join('config/parcel_gift_journey.yml'), permitted_classes: [], permitted_symbols: [], aliases: false) }

  describe 'checked-in guidance' do
    let(:labels) do
      [
        'I’ve been asked to pay a charge on a parcel',
        'I want to know what tax I might pay on a parcel sent to me',
        'I’m sending a parcel or gift overseas',
        'I’m bringing goods into the UK in my luggage',
        'I’m moving to the UK with my belongings',
      ]
    end
    let(:titles) do
      [
        'I’ve been asked to pay a charge on a parcel',
        'I want to know what I might pay on a parcel sent to me',
        'I’m sending a parcel or gift overseas',
        'I’m bringing goods into the UK in my luggage',
        'I’m moving to the UK with my personal belongings',
      ]
    end
    let(:paths) do
      %w[
        i-have-been-asked-to-pay-a-charge-before-a-parcel-is-delivered
        i-want-to-know-what-i-might-pay-on-something-coming-from-abroad
        i-am-sending-a-parcel-or-gift-to-someone-abroad
        i-wish-to-bring-goods-back-from-overseas-in-personal-luggage
        i-am-moving-to-the-uk-and-bringing-my-belongings
      ]
    end
    let(:breadcrumbs) do
      [
        'A charge on a parcel',
        'Tax on a parcel sent to you',
        'Sending a parcel or gift overseas',
        'Goods in personal baggage',
        'Moving to the UK with personal belongings',
      ]
    end

    it 'loads the shared draft journey in choice order', :aggregate_failures do
      expect(journey).to have_attributes(base_path: 'parcels-and-gifts', feature_flag: 'parcel_gift_journey')
      expect(journey.chooser).to have_attributes(
        route_name: 'parcel_gift_journey',
        title: 'What do you need help with?',
        error: 'Select what you need help with',
        submit_label: 'Continue',
        services: %w[uk xi],
        fallback_heading: 'Need help with something else?',
        fallback_text: 'Give as much detail as you can.',
      )
      expect(journey.homepage).to have_attributes(
        title: 'Parcels, gifts, belongings',
        description: 'Check charges, tax and duty when sending or receiving items.',
      )
      expect(journey.steps.map(&:id)).to eq(%w[parcel_charges incoming_tax sending_overseas personal_baggage moving_belongings])
      expect(journey.steps.map(&:label)).to eq(labels)
      expect(journey.steps.map(&:title)).to eq(titles)
      expect(journey.steps.map(&:path)).to eq(paths)
      expect(journey.steps.map(&:breadcrumb)).to eq(breadcrumbs)
      expect(journey.steps).to all(have_attributes(services: %w[uk xi]))
      expect(journey.steps_for('uk').map(&:id)).to eq(journey.steps_for(:xi).map(&:id))
    end

    it 'orders prototype content, details and structured links', :aggregate_failures do
      overseas = journey.find_step('sending_overseas', service_name: 'uk')
      links = journey.steps.flat_map(&:sections).flat_map(&:links)

      expect(links.select(&:button)).to contain_exactly(
        have_attributes(text: 'Search for a commodity code', target: 'commodity_search', new_tab: false),
      )
      expect(overseas.sections.first.details).to have_attributes(summary: 'What a commodity code is used for')
      expect(overseas.sections.first.details.links).to contain_exactly(
        have_attributes(text: 'Read how to find a commodity code', target: 'https://www.gov.uk/guidance/finding-commodity-codes-for-imports-or-exports', new_tab: true, suffix: '.'),
      )
      expect(overseas.sections.last.content).to include('What the person receiving it might pay')
      expect(overseas.sections.first.details.content).to include('not the parcel or the reason for sending it')
      expect(links.map(&:target)).to include('https://www.gov.uk/guidance/application-for-transfer-of-residence-relief-tor1')
    end

    it 'freezes the definition and every nested content record' do
      step = journey.steps.first
      section = step.sections.first
      link = section.links.first
      details = journey.find_step('sending_overseas', service_name: 'uk').sections.first.details

      expect([journey, journey.chooser, journey.chooser.title, journey.homepage, journey.homepage.description,
              journey.steps, step, step.label, step.breadcrumb, step.services, step.services.first,
              step.sections, section, section.content, section.links, link, link.text, link.target, link.prefix,
              details, details.summary, details.content, details.links, details.links.first,
              details.links.first.text, details.links.first.target, details.links.first.suffix]).to all(be_frozen)
    end
  end

  describe 'optional link fields' do
    let(:config) { valid_config }

    it 'defaults omitted suffixes and details links', :aggregate_failures do
      config['steps'].first['sections'].first['details'] = { 'summary' => 'Help', 'content' => 'Explanation' }

      section = journey.steps.first.sections.first
      expect(section.links.first.suffix).to be_nil
      expect(section.details.links).to be_empty
      expect(section.details.links).to be_frozen
    end
  end

  describe 'service filtering' do
    let(:config) { valid_config.tap { |raw| raw['steps'].first['services'] = %w[uk] } }

    it 'returns a visible step or nil', :aggregate_failures do
      expect(journey.find_step('parcel_charges', service_name: :uk)&.id).to eq('parcel_charges')
      expect(journey.find_step('parcel_charges', service_name: 'xi')).to be_nil
      expect(journey.find_step('missing', service_name: 'uk')).to be_nil
      expect(journey.steps_for('xi')).to be_empty
    end
  end

  describe 'invalid configuration' do
    it 'rejects a shape that is not the journey object' do
      expect { described_class.new([], service_names: %w[uk]) }.to raise_error(described_class::ConfigurationError, /configuration must be a key-value object/)
    end

    it 'rejects empty service configuration' do
      expect { described_class.new(valid_config, service_names: []) }.to raise_error(described_class::ConfigurationError, /service_names must not be empty/)
    end

    it 'rejects an unknown root key' do
      expect { described_class.new(valid_config.merge('blocks' => []), service_names: %w[uk xi]) }
        .to raise_error(described_class::ConfigurationError, /unknown key blocks/)
    end

    it 'rejects a chooser route that collides with a step name' do
      changed = valid_config
      changed['chooser']['route_name'] = 'parcel_charges'

      expect { described_class.new(changed, service_names: %w[uk xi]) }
        .to raise_error(described_class::ConfigurationError, /chooser route_name must be distinct/)
    end

    it 'rejects duplicate step paths' do
      changed = valid_config
      changed['steps'] << changed['steps'].first.merge('id' => 'other_step', 'route_name' => 'other_step')

      expect { described_class.new(changed, service_names: %w[uk xi]) }
        .to raise_error(described_class::ConfigurationError, /field path duplicates/)
    end

    [
      ['base_path', '../parcels', /base_path must be a lowercase hyphenated slug/],
      ['feature_flag', 'ParcelGift', /feature_flag must be a lowercase snake_case identifier/],
    ].each do |field, value, message|
      it "rejects #{field} #{value.inspect}" do
        expect { described_class.new(valid_config.merge(field => value), service_names: %w[uk xi]) }
          .to raise_error(described_class::ConfigurationError, message)
      end
    end

    it 'rejects an empty service list and an unsupported service', :aggregate_failures do
      empty = valid_config
      empty['steps'].first['services'] = []
      expect { described_class.new(empty, service_names: %w[uk xi]) }
        .to raise_error(described_class::ConfigurationError, /services must not be empty/)

      unknown = valid_config
      unknown['chooser']['services'] = %w[uk eu]
      expect { described_class.new(unknown, service_names: %w[uk xi]) }
        .to raise_error(described_class::ConfigurationError, /unsupported service eu/)
    end

    [
      'javascript:alert(1)',
      'http://www.gov.uk/goods-sent-from-abroad',
      'https://gov.uk/goods-sent-from-abroad',
      'https://user@www.gov.uk/goods-sent-from-abroad',
      'https://www.gov.uk.evil.example/goods',
      'https://www.gov.uk/goods/../../admin',
      'enquiry',
      'find_commodity_path',
    ].each do |target|
      it "rejects link target #{target}" do
        changed = valid_config
        changed['steps'].first['sections'].first['links'].first['target'] = target

        expect { described_class.new(changed, service_names: %w[uk xi]) }
          .to raise_error(described_class::ConfigurationError, /target/)
      end
    end

    it 'rejects HTML and ERB in guidance content' do
      changed = valid_config
      changed['steps'].first['sections'].first['content'] = 'See <%= link_to "pay" %> now'

      expect { described_class.new(changed, service_names: %w[uk xi]) }
        .to raise_error(described_class::ConfigurationError, /markdown without HTML/)
    end

    ['# Another page heading', "Another heading\n===\n", "[Unexpected link][target]\n\n[target]: //example.com"].each do |content|
      it 'keeps headings and links controlled' do
        changed = valid_config
        changed['steps'].first['sections'].first['content'] = content
        expect { described_class.new(changed, service_names: %w[uk xi]) }
          .to raise_error(described_class::ConfigurationError, /markdown without HTML/)
      end
    end

    [nil, [], 'content'].each do |sections|
      it "rejects invalid sections #{sections.inspect}" do
        changed = valid_config
        changed['steps'].first['sections'] = sections
        expect { described_class.new(changed, service_names: %w[uk xi]) }
          .to raise_error(described_class::ConfigurationError, /sections must be a non-empty list/)
      end
    end

    [
      {},
      { 'template' => 'arbitrary' },
      { 'details' => { 'summary' => 'Help', 'content' => '<script>unsafe</script>' } },
      { 'details' => { 'summary' => '', 'content' => 'Explanation' } },
      { 'details' => { 'summary' => 'Help', 'content' => 'Explanation', 'open' => true } },
    ].each do |section|
      it "rejects an invalid content section #{section.inspect}" do
        changed = valid_config
        changed['steps'].first['sections'] = [section]
        expect { described_class.new(changed, service_names: %w[uk xi]) }
          .to raise_error(described_class::ConfigurationError)
      end
    end

    it 'validates links inside details' do
      changed = valid_config
      changed['steps'].first['sections'].first['details'] = {
        'summary' => 'Help',
        'content' => 'Explanation',
        'links' => [valid_link.merge('target' => 'javascript:alert(1)')],
      }

      expect { described_class.new(changed, service_names: %w[uk xi]) }
        .to raise_error(described_class::ConfigurationError, /details link 0 target/)
    end

    it 'rejects non-text link suffixes' do
      changed = valid_config
      changed['steps'].first['sections'].first['links'].first['suffix'] = false

      expect { described_class.new(changed, service_names: %w[uk xi]) }
        .to raise_error(described_class::ConfigurationError, /suffix must be text/)
    end

    it 'rejects a string used as a boolean' do
      changed = valid_config
      changed['steps'].first['sections'].first['links'].first['new_tab'] = 'true'

      expect { described_class.new(changed, service_names: %w[uk xi]) }
        .to raise_error(described_class::ConfigurationError, /new_tab must be true or false/)
    end
  end

  def valid_config
    {
      'base_path' => 'parcels-and-gifts',
      'feature_flag' => 'parcel_gift_journey',
      'chooser' => {
        'route_name' => 'parcel_gift_journey',
        'title' => 'What do you need help with?',
        'error' => 'Select what you need help with',
        'submit_label' => 'Continue',
        'services' => %w[uk xi],
        'fallback_heading' => 'Need help with something else?',
        'fallback_text' => 'Submit a question and provide as much detail as possible.',
      },
      'homepage' => {
        'title' => 'Send or receive a personal parcel, gift or belongings',
        'description' => 'Help with parcels, gifts and belongings.',
      },
      'steps' => [
        {
          'id' => 'parcel_charges',
          'path' => 'a-charge-on-a-parcel',
          'route_name' => 'parcel_gift_charges',
          'label' => 'I have been asked to pay a charge before a parcel is delivered',
          'title' => 'A charge on a parcel',
          'breadcrumb' => 'A charge on a parcel',
          'services' => %w[uk xi],
          'sections' => [{
            'content' => 'Customs may check a parcel sent to Great Britain or Northern Ireland.',
            'links' => [valid_link],
          }],
        },
      ],
    }
  end

  def valid_link
    {
      'text' => 'Tax and customs for goods sent from abroad',
      'target' => 'https://www.gov.uk/goods-sent-from-abroad/tax-and-duty',
      'new_tab' => true,
      'button' => false,
    }
  end
end
