require 'spec_helper'

RSpec.describe 'Parcel and gift guidance', type: :request do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  let(:journey) { Rails.configuration.parcel_gift_journey }
  let(:page) { Capybara.string(response.body) }

  before { allow(ENV).to receive(:[]).and_call_original }

  %w[uk xi].each do |service|
    context "with the #{service} service" do
      let(:start_path) { "/#{service}/#{journey.base_path}" }

      context 'when the flag is off' do
        before { disable_feature(:parcel_gift_journey) }

        it 'hides the chooser and destinations', :aggregate_failures do
          [start_path, *journey.steps.map { |step| "#{start_path}/#{step.path}" }].each do |path|
            get path
            expect(response).to have_http_status(:not_found)
          end
        end

        it 'does not accept a choice' do
          get start_path, params: { parcel_gift_choice_form: { choice: 'parcel_charges' } }
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the flag is on' do
        before { enable_feature(:parcel_gift_journey) }

        it 'renders ordered unselected choices', :aggregate_failures do
          get start_path

          expect(response).to have_http_status(:ok)
          expect(page).to have_css('h1', text: journey.chooser.title)
          expect(page).to have_css('[role="navigation"][aria-label="Breadcrumb"] [aria-current="page"]', text: journey.chooser.title, exact_text: true)
          expect(page.all('input[type="radio"]').map { |radio| radio[:value] }).to eq(journey.steps.map(&:id))
          expect(page).not_to have_css('input[type="radio"][checked]')
          expect(page).to have_link('Enquiry form', href: %r{/enquiry_form})
          expect(page).not_to have_css('form#new_search')
          expect(page).to have_css('form[method="get"] input[type="hidden"][name="parcel_gift_choice_form[choice]"][value=""]', visible: :all)
          expect(page).not_to have_css('input[name="authenticity_token"]', visible: :all)
          expect(response.headers['X-Robots-Tag']).to eq('noindex, nofollow')
        end

        it 'routes each choice to its guidance', :aggregate_failures do
          journey.steps.each do |step|
            get start_path, params: { parcel_gift_choice_form: { choice: step.id } }
            expect(response).to have_http_status(:see_other)
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(Capybara.string(response.body)).to have_css('h1', text: step.title)
          end
        end

        it 'allows guidance without a session', :aggregate_failures do
          journey.steps.each do |step|
            get "#{start_path}/#{step.path}"
            expect(response).to have_http_status(:ok)
            guidance_page = Capybara.string(response.body)
            expect(guidance_page).to have_css('.tariff-markdown')
            expect(guidance_page).to have_link(journey.chooser.title, href: %r{/parcels-and-gifts\z})
            expect(guidance_page).to have_css('[role="navigation"][aria-label="Breadcrumb"] [aria-current="page"]', text: step.breadcrumb, exact_text: true)
          end
        end

        %w[parcel_charges incoming_tax sending_overseas].each do |step_id|
          it "renders #{step_id} lists with GOV.UK Markdown styling", :aggregate_failures do
            step = journey.find_step(step_id, service_name: service)
            get "#{start_path}/#{step.path}"

            expect(page).to have_css('.tariff-markdown ul li')
            expect(page.all('main .tariff-markdown ul').size).to eq(page.all('main ul').size)
          end
        end

        [{ choice: '' }, { choice: 'unknown' }, { choice: %w[parcel_charges] }, { choice: { id: 'parcel_charges' } }].each do |values|
          it "rejects invalid selection #{values.inspect}", :aggregate_failures do
            get start_path, params: { parcel_gift_choice_form: values }

            expect(response).to have_http_status(:unprocessable_content)
            expect(page).to have_css('.govuk-error-summary', text: journey.chooser.error)
            expect(page).to have_css('.govuk-error-message', text: journey.chooser.error)
            expect(page).to have_css('title', text: /Error:/, visible: :all)
          end
        end

        it 'rejects a malformed form envelope' do
          get start_path, params: { parcel_gift_choice_form: 'parcel_charges' }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'ignores a forged route step' do
          get "#{start_path}/#{journey.steps.first.path}", params: { step_id: 'sending_overseas' }
          expect(page).to have_css('h1', text: journey.steps.first.title)
        end

        it 'links to the guided search form in the same service' do
          step = journey.find_step('sending_overseas', service_name: service)
          get "#{start_path}/#{step.path}"
          href = page.find_link('Search for a commodity code')[:href]
          expected_path = service == 'xi' ? '/xi/find_commodity' : '/find_commodity'
          expect(href).to eq("#{expected_path}?search_mode=guided#new_search")
        end

        [true, false].each do |ai_enabled|
          it "follows the search link with AI enabled=#{ai_enabled}", :aggregate_failures do
            ai_enabled ? enable_feature(:interactive_search) : disable_feature(:interactive_search)
            cookies[:interactive_search] = 'false'
            step = journey.find_step('sending_overseas', service_name: service)
            get "#{start_path}/#{step.path}"
            destination = URI.join(request.base_url, Capybara.string(response.body).find_link('Search for a commodity code')[:href])

            get destination.request_uri

            expected_mode = service == 'uk' && ai_enabled ? 'guided' : 'keyword'
            search_page = Capybara.string(response.body)
            expect(response).to have_http_status(:ok)
            expect(destination.fragment).to eq('new_search')
            expect(search_page).to have_css("form#new_search[data-search-mode-initial-mode-value='#{expected_mode}']")
            if expected_mode == 'guided'
              expect(search_page).to have_css('#ai-search-tab', visible: :all)
            else
              expect(search_page).not_to have_css('#ai-search-tab', visible: :all)
            end
          end
        end

        it 'renders the commodity explanation before the search button and receiving guidance', :aggregate_failures do
          step = journey.find_step('sending_overseas', service_name: service)
          get "#{start_path}/#{step.path}"

          expect(page).to have_css('details.govuk-details summary', text: 'What a commodity code is used for')
          expect(page).to have_css('details .tariff-markdown', text: 'A commodity code describes the item you are sending.', visible: :all)
          expect(response.body.index('<details')).to be < response.body.index('Search for a commodity code')
          expect(response.body.index('Search for a commodity code')).to be < response.body.index('What the person receiving')
          expect(page).to have_css('h2', text: 'Getting help from HMRC')
          expect(page).to have_link('Enquiry form', href: %r{/enquiry_form/postal_or_baggage_details\?parcel_gift_step=sending_overseas})
        end

        it 'rejects a service-excluded step', :aggregate_failures do
          raw = YAML.safe_load_file(Rails.root.join('config/parcel_gift_journey.yml'))
          raw.fetch('steps').first['services'] = [service == 'uk' ? 'xi' : 'uk']
          restricted = TradeTariffFrontend::ParcelGiftJourney.new(raw, service_names: %w[uk xi])
          allow(Rails.configuration).to receive(:parcel_gift_journey).and_return(restricted)

          get start_path
          expect(page).not_to have_field('parcel_gift_choice_form[choice]', with: 'parcel_charges', type: 'radio')
          get start_path, params: { parcel_gift_choice_form: { choice: 'parcel_charges' } }
          expect(response).to have_http_status(:unprocessable_content)
          get "#{start_path}/#{restricted.steps.first.path}"
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  context 'when flag evaluation fails' do
    before do
      allow(ENV).to receive(:[]).with('PARCEL_GIFT_JOURNEY').and_return(nil)
      allow(TEST_FLAGSMITH_CLIENT).to receive(:get_flags_for).and_raise(StandardError, 'unavailable')
    end

    it 'falls back to disabled' do
      get '/parcels-and-gifts'
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when the flag is missing' do
    before { allow(ENV).to receive(:[]).with('PARCEL_GIFT_JOURNEY').and_return(nil) }

    it 'falls back to disabled' do
      get '/parcels-and-gifts'
      expect(response).to have_http_status(:not_found)
    end
  end
end
