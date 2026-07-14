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

          expect(page.find('#autocomplete input.autocomplete__input')).to be_present
        end
      end

      it 'submits the full typed query when submitting immediately after fast input' do
        VCR.use_cassette('search#check') do
          visit find_commodity_path

          page.execute_script <<~JS
            window.submittedSearchQuery = null;
            document.addEventListener('click', function(event) {
              if (!event.target.closest('#new_search')) return;
              if (event.target.closest('#autocomplete')) return;

              event.preventDefault();
              window.submittedSearchQuery = new FormData(document.querySelector('#new_search')).get('q');
            }, true);
          JS

          autocomplete_input = page.find('#search-q-field')
          autocomplete_input.click
          autocomplete_input.send_keys('tahini')
          expect(autocomplete_input.value).to eq('tahini')

          page.execute_script <<~JS
            document.querySelector('#search-q-field').value = 'tahini paste';
          JS

          page.find('#new_search button[type="submit"]').click

          expect(page.evaluate_script('window.submittedSearchQuery')).to eq('tahini paste')
        end
      end

      it 'submits the full typed query when enter would confirm a stale autocomplete suggestion' do
        VCR.use_cassette('search#check') do
          visit find_commodity_path

          page.execute_script <<~JS
            window.submittedSearchQuery = null;
            window.GOVUK.Utility.fetchCommoditySearchSuggestions = function(query, searchSuggestionsPath, options, populateResults) {
              populateResults(['tahini']);
            };
            HTMLFormElement.prototype.submit = function() {
              window.submittedSearchQuery = new FormData(this).get('q');
            };
          JS

          autocomplete_input = page.find('#search-q-field')
          autocomplete_input.click
          autocomplete_input.send_keys('tahini')

          expect(page).to have_css('#autocomplete [role="option"]', text: 'tahini')

          autocomplete_input.send_keys(' paste')
          autocomplete_input.send_keys(:enter)

          expect(page.evaluate_script('window.submittedSearchQuery')).to eq('tahini paste')
        end
      end

      it 'submits an explicitly clicked suggestion when it is shorter than the typed query' do
        VCR.use_cassette('search#check') do
          visit find_commodity_path

          page.execute_script <<~JS
            window.submittedSearchQuery = null;
            window.GOVUK.Utility.fetchCommoditySearchSuggestions = function(query, searchSuggestionsPath, options, populateResults) {
              if (query === 'tahini') populateResults(['tahini']);
            };
            HTMLFormElement.prototype.submit = function() {
              window.submittedSearchQuery = new FormData(this).get('q');
            };
          JS

          autocomplete_input = page.find('#search-q-field')
          autocomplete_input.send_keys('tahini')
          expect(page).to have_css('#autocomplete [role="option"]', text: 'tahini')

          page.execute_script <<~JS
            const input = document.querySelector('#search-q-field');
            input.value = 'tahini paste';
            input.dispatchEvent(new Event('input', { bubbles: true }));
          JS
          page.find('#autocomplete [role="option"]', text: 'tahini').click

          expect(page.evaluate_script('window.submittedSearchQuery')).to eq('tahini')
        end
      end

      it 'submits an explicitly selected suggestion after arrow key navigation' do
        VCR.use_cassette('search#check') do
          visit find_commodity_path

          page.execute_script <<~JS
            window.submittedSearchQuery = null;
            window.GOVUK.Utility.fetchCommoditySearchSuggestions = function(query, searchSuggestionsPath, options, populateResults) {
              if (query === 'tahini') populateResults(['tahini paste']);
            };
            HTMLFormElement.prototype.submit = function() {
              window.submittedSearchQuery = new FormData(this).get('q');
            };
          JS

          autocomplete_input = page.find('#search-q-field')
          autocomplete_input.send_keys('tahini')
          expect(page).to have_css('#autocomplete [role="option"]', text: 'tahini paste')

          autocomplete_input.send_keys(:down)
          autocomplete_input.send_keys(:enter)

          expect(page.evaluate_script('window.submittedSearchQuery')).to eq('tahini paste')
        end
      end
    end

    context 'when using guided search' do
      before do
        enable_feature(:interactive_search)
        allow(TradeTariffFrontend).to receive(:webchat_url).and_return('https://example.com/webchat')

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
          expect(page.find('#quota_search_form_as_of_3i')).to be_present
          expect(page.find('#quota_search_form_as_of_2i')).to be_present
          expect(page.find('#quota_search_form_as_of_1i')).to be_present
          expect(page).to have_css('button[name="new_search"], input[name="new_search"]')

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
          page.find('#quota_search_form_as_of_3i').set('14')
          page.find('#quota_search_form_as_of_2i').set('7')
          page.find('#quota_search_form_as_of_1i').set('2025')
          page.find('button[name="new_search"], input[name="new_search"]').click

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
          expect(page.find('button[name="new_search"]')).to be_present

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
          page.find('button[name="new_search"]').click

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
          page.find('button[name="new_search"]').click

          expect(page).to have_content('Chemical search results for “benzene”')
          expect(page).to have_content('22199-08-2')
          expect(page).to have_content('4-amino-N-(pyrimidin-2(1H)-ylidene-κN 1)benzenesulfonamidato-κOsilver')
          expect(page).to have_link('Other', href: '/commodities/2843290000')
        end
      end
    end
  end
end
