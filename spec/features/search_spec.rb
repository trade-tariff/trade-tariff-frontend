require 'spec_helper'

RSpec.describe 'Search', :js do
  context 'with find_commodity page' do
    include_context 'with latest news stubbed'
    include_context 'with news updates stubbed'

    context 'when reaching the search page' do
      it 'renders the search container properly' do
        VCR.use_cassette('search#check') do
          visit find_commodity_path

          expect(page).to have_content('UK Integrated Online Tariff')
          expect(page).to have_content('Look up commodity codes, duty and VAT rates')
          expect(page).to have_content('Search')
          expect(page).to have_content('Browse')

          expect(page.find('#autocomplete input')).to be_present
        end
      end
    end

    context 'when using guided search' do
      before do
        # Stub Flipper.enabled? at the module level so the flag is visible to
        # the Puma server thread as well as the test thread. Using
        # Flipper.enable writes to the shared Memory adapter but each Puma
        # thread holds its own thread-local Flipper.instance, which can
        # produce timing-sensitive cross-thread visibility issues in JS tests.
        # A module-level stub avoids that entirely.
        allow(Flipper).to receive(:enabled?).and_call_original
        allow(Flipper).to receive(:enabled?).with(:interactive_search, anything).and_return(true)
        allow(TradeTariffFrontend).to receive_messages(
          enquiries_email: 'classification.enquiries@hmrc.gov.uk',
          webchat_url: 'https://example.com/webchat',
        )

        stub_api_request('search', :post, internal: true).to_return(
          {
            status: 200,
            body: {
              'data' => [guided_search_result],
              'meta' => {
                'interactive_search' => {
                  'query' => 'smoked haddock',
                  'request_id' => 'guided-request-123',
                  'result_limit' => 5,
                  'answers' => [
                    { 'question' => 'What type of fish?', 'options' => %w[Haddock Salmon], 'answer' => nil },
                  ],
                },
              },
            }.to_json,
            headers: { 'content-type' => 'application/json; charset=utf-8' },
          },
          {
            status: 200,
            body: {
              'data' => [],
              'meta' => {
                'interactive_search' => {
                  'query' => 'smoked haddock',
                  'request_id' => 'guided-request-123',
                  'answers' => [
                    { 'question' => 'What type of fish?', 'options' => %w[Haddock Salmon], 'answer' => 'Haddock' },
                  ],
                },
                'description_intercept' => {
                  'excluded' => true,
                  'message_header' => 'Example guidance header',
                  'message' => 'Use [Ask HMRC online]({{webchat_url}}) for classification help.',
                },
              },
            }.to_json,
            headers: { 'content-type' => 'application/json; charset=utf-8' },
          },
        )
      end

      let(:guided_search_result) do
        {
          'id' => '2007919930',
          'type' => 'commodity',
          'attributes' => {
            'goods_nomenclature_item_id' => '2007919930',
            'producline_suffix' => GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX,
            'goods_nomenclature_class' => 'Commodity',
            'description' => 'Smoked fish',
            'formatted_description' => 'Smoked fish',
            'classification_description' => 'Smoked fish',
            'self_text' => 'Smoked fish',
            'declarable' => true,
            'score' => 12.5,
            'confidence' => 'strong',
          },
        }
      end

      it 'submits the journey and renders final intercept links with new-tab attributes' do
        visit find_commodity_path

        choose 'Guided search'
        fill_in 'Describe the products you are trading', with: 'smoked haddock'
        click_button 'Search for a commodity'

        expect(page).to have_css('h1', text: 'Search for a commodity')
        expect(page).to have_content('What type of fish?')

        choose 'Haddock'
        click_button 'Submit'

        expect(page).to have_css('h1', text: 'Example guidance header')
        expect(page).to have_content('Use Ask HMRC online for classification help.')
        expect(page).to have_link('Ask HMRC online', href: 'https://example.com/webchat')

        message = page.find('p.govuk-body', text: 'Use Ask HMRC online for classification help.')
        link = message.find('a[href="https://example.com/webchat"]', text: 'Ask HMRC online')
        expect(link[:target]).to eq('_blank')
        expect(link[:rel].split).to include('noopener', 'noreferrer')
        expect(link).not_to have_css('.govuk-visually-hidden', text: '(opens in new tab)')
      end

      it 'only shows the unknown answer guidance after submitting the unknown option' do
        visit find_commodity_path

        choose 'Guided search'
        fill_in 'Describe the products you are trading', with: 'smoked haddock'
        click_button 'Search for a commodity'

        expect(page).to have_css('h1', text: 'Search for a commodity')
        expect(page).to have_content('What type of fish?')

        choose "I don't know"

        expect(page).to have_content('What type of fish?')
        dont_know = page.find('[data-interactive-question-target="dontKnow"]', visible: :all)
        expect(dont_know[:class]).to include('govuk-!-display-none')

        click_button 'Submit'

        dont_know = page.find('[data-interactive-question-target="dontKnow"]', visible: :all)
        expect(dont_know[:class]).not_to include('govuk-!-display-none')
        expect(dont_know).to have_css('h1', text: "We can't suggest a tariff code yet")
        expect(dont_know).to have_content('To find the relevant commodity code, we need more information about the product.')
      end
    end
  end

  context 'when doing a full quota search' do
    context 'when reaching the quota search form' do
      it 'contains quota search params inputs' do
        VCR.use_cassette('search#quota_search_form') do
          visit quota_search_path

          expect(page).to have_content('Quotas')

          expect(page.find('#goods_nomenclature_item_id')).to be_present
          expect(page.find('#geographical_area_id')).to be_present
          expect(page.find('#order_number')).to be_present
          expect(page.find('#critical')).to be_present
          expect(page.find('#status')).to be_present
          expect(page.find('#day')).to be_present
          expect(page.find('#month')).to be_present
          expect(page.find('#year')).to be_present
          expect(page.find('input[name="new_search"]')).to be_present

          expect(page.find('.autocomplete__wrapper')).to be_present

          expect(page).not_to have_content('Quota search results')
        end
      end
    end

    context 'when getting back some quota search results' do
      it 'performs search and render results' do
        VCR.use_cassette('search#quota_search_results') do
          visit quota_search_path

          expect(page).to have_content('Quotas')

          page.find('#order_number').set('050088')
          page.find('#day').set('14')
          page.find('#month').set('7')
          page.find('#year').set('2025')
          page.find('input[name="new_search"]').click

          expect(page).to have_content('Quota search results')
          expect(page).to have_content('050088')
          expect(page).to have_link('2106909800', href: '/subheadings/2106909800-80?day=14&month=7&year=2025')
          expect(page).to have_content('All countries (1011)')
        end
      end
    end
  end

  describe 'when reaching the tools page' do
    it 'has the Tools link present on the page' do
      visit tools_path

      expect(page).to have_content('Tools')
    end
  end

  context 'when using the chemical search' do
    let(:name) { 'CAS' }

    context 'when reaching the chemical search form' do
      it 'contains chemical search params inputs' do
        VCR.use_cassette('search#chemical_search_form') do
          visit chemical_search_path

          expect(page.find('#cas')).to be_present
          expect(page.find('#name')).to be_present
          expect(page.find('input[name="new_search"]')).to be_present

          expect(page).not_to have_content('Chemical search results')
        end
      end
    end

    context 'when getting back some chemical search results' do
      it 'performs search by CAS number and render results' do
        VCR.use_cassette('search#chemical_cas_search_results') do
          visit chemical_search_path

          expect(page).to have_content(name)

          page.find('#cas').set('121-17-5')
          page.find('input[name="new_search"]').click

          expect(page).to have_content('Chemical search results for “121-17-5”')
          expect(page).to have_content('4-chloro-alpha,alpha,alpha-trifluoro-3-nitrotoluene')
          expect(page).to have_link('Other', href: '/commodities/2904990000')
        end
      end

      it 'performs search by chemical name and render results' do
        VCR.use_cassette('search#chemical_name_search_results') do
          visit chemical_search_path

          expect(page).to have_content(name)

          page.find('#name').set('benzene')
          page.find('input[name="new_search"]').click

          expect(page).to have_content('Chemical search results for “benzene”')
          expect(page).to have_content('22199-08-2')
          expect(page).to have_content('4-amino-N-(pyrimidin-2(1H)-ylidene-κN 1)benzenesulfonamidato-κOsilver')
          expect(page).to have_link('Other', href: '/commodities/2843290000')
        end
      end
    end
  end
end
