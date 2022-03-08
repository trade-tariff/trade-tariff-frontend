require 'spec_helper'

RSpec.describe 'Commodity page', type: :request do
  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))

    allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:xi).and_call_original
    allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:uk).and_call_original
    allow(GeographicalArea).to receive(:find).with('AD').and_return(build(:geographical_area, id: 'AD', description: 'Andorra'))
    allow(RulesOfOrigin::Scheme).to receive(:all).and_return([])

    TradeTariffFrontend::ServiceChooser.service_choice = nil
  end

  shared_examples_for 'loads the correct uk declarables' do
    it { expect(TradeTariffFrontend::ServiceChooser).not_to have_received(:with_source).with(:xi) }
    it { expect(TradeTariffFrontend::ServiceChooser).to have_received(:with_source).with(:uk) }
  end

  shared_examples_for 'loads the correct xi declarables' do
    it { expect(TradeTariffFrontend::ServiceChooser).to have_received(:with_source).with(:xi) }
    it { expect(TradeTariffFrontend::ServiceChooser).to have_received(:with_source).with(:uk) }
  end

  it_behaves_like 'loads the correct uk declarables' do
    before do
      VCR.use_cassette('commodities#0101300000#uk') do
        get '/commodities/0101300000' # Validate UK commodity
      end
    end
  end

  it_behaves_like 'loads the correct xi declarables' do
    before do
      VCR.use_cassette('commodities#0101300000#xi') do
        get '/xi/commodities/0101300000' # Validate XI commodity
      end
    end
  end

  it_behaves_like 'loads the correct uk declarables' do
    before do
      VCR.use_cassette('commodities#0501000000#uk') do
        get '/commodities/0501000000' # Validate UK declarable heading
      end
    end
  end

  it_behaves_like 'loads the correct xi declarables' do
    before do
      VCR.use_cassette('commodities#0501000000#xi') do
        get '/xi/commodities/0501000000' # Validate XI declarable heading
      end
    end
  end

  context 'when mime type is HTML' do
    it 'displays declarable related information' do
      VCR.use_cassette('commodities#0101300000.html') do
        get '/commodities/0101300000'

        expect(response).to be_successful
      end
    end
  end

  context 'when mime type is JSON' do
    context 'when requested with json format' do
      it 'renders a valid JSON response' do
        VCR.use_cassette('commodities#0101300000.json') do
          get '/commodities/0101300000.json'

          expect {
            JSON.parse(response.body)
          }.not_to raise_error
        end
      end
    end

    context 'when requested with json HTTP Accept header' do
      it 'renders direct API response' do
        VCR.use_cassette('commodities#0101300000_accept_json') do
          get '/commodities/0101300000', headers: { 'HTTP_ACCEPT' => 'application/json' }

          expect {
            JSON.parse(response.body)
          }.not_to raise_error
        end
      end
    end
  end

  context 'when commodity with country filter' do
    it 'will not display measures for other countries except for selected one' do
      VCR.use_cassette('headings#show_0101') do
        visit commodity_path('6911100090', country: 'AD')

        expect(page).not_to have_content 'Definitive anti-dumping duty'
      end
    end
  end

  context 'when commodity with national measurement units' do
    it 'renders successfully' do
      VCR.use_cassette('commodities#2208909110') do
        visit commodity_path('2208909110')

        within('#import') do
          expect(page).to have_content 'l alc. 100%'
        end
      end
    end
  end

  context 'when commodity with whatever' do
    before do
      VCR.use_cassette('commodities#0101300000.html') do
        visit commodity_path('0101300000')
      end
    end

    it 'displays the link to find commodity' do
      expect(page).to have_link 'Search',
                                href: '/find_commodity'
    end

    it 'displays the section as a link' do
      expect(page).to have_link 'Section I',
                                href: '/sections/1'
    end

    it 'displays the chapter name as a link' do
      expect(page).to have_link 'Chapter 01',
                                href: '/chapters/01'
    end

    it 'displays the header name as a link' do
      expect(page).to have_link 'Heading 0101',
                                href: '/headings/0101'
    end

    it 'displays the commodity classification' do
      expect(page).to have_content 'Asses'
    end
  end
end
