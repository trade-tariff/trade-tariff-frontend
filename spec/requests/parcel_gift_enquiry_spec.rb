require 'spec_helper'

RSpec.describe 'Enquiries from parcel guidance', :aggregate_failures, type: :request do
  let(:journey) { Rails.configuration.parcel_gift_journey }

  around do |example|
    old_cache_store = ProductExperience::EnquiryFormDraftStore.instance_variable_get(:@cache_store)
    ProductExperience::EnquiryFormDraftStore.cache_store = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    ProductExperience::EnquiryFormDraftStore.cache_store = old_cache_store
  end

  before { enable_feature(:parcel_gift_journey) }

  %w[uk xi].each do |service|
    context "with the #{service} service" do
      let(:prefix) { service == 'xi' ? '/xi' : '' }
      let(:details_path) { "#{prefix}/enquiry_form/postal_or_baggage_details" }
      let(:step) { journey.steps.first }
      let(:guidance_path) { "#{prefix}/#{journey.base_path}/#{step.path}" }

      %w[parcel_charges incoming_tax sending_overseas moving_belongings personal_baggage].each do |step_id|
        it "starts a postal enquiry from #{step_id} and links Back to its guidance" do
          outcome = journey.find_step(step_id, service_name: service)
          origin = "#{prefix}/#{journey.base_path}/#{outcome.path}"
          get origin
          link = document.find_link('Enquiry form')[:href]

          expect(URI.parse(link).path).to eq(details_path)
          get link

          expect(response).to have_http_status(:ok)
          expect(document).to have_css('h1', text: 'Tell us about your postal or baggage question')
          expect(document).to have_link('Back', href: origin)
        end
      end

      it 'preserves the originating page through validation, refresh, contact details and submission' do
        get details_path, params: { parcel_gift_step: step.id, request_id: 'search-123', return_to: 'https://example.com' }
        token = document.find('input[name="submission_token"]', visible: :all)[:value]
        post details_path, params: { submission_token: token, item: 'Book' }

        expect(document).to have_css('.govuk-error-summary')
        expect(document).to have_link('Back', href: guidance_path)

        get details_path, params: { parcel_gift_step: step.id }
        expect(document).to have_field('What is the item?', with: 'Book')
        expect(document.find('input[name="submission_token"]', visible: :all)[:value]).to eq(token)

        post details_path, params: {
          submission_token: token,
          postal_or_baggage: 'sent_by_post',
          item: 'Book',
          purchase_price: '40',
          query: 'Please explain the charge on this parcel.',
        }
        expect(response).to redirect_to("#{prefix}/enquiry_form/contact_details")
        follow_redirect!
        expect(document).to have_link('Back', href: details_path)
        get document.find_link('Back')[:href]
        expect(document).to have_link('Back', href: guidance_path)

        post "#{prefix}/enquiry_form/contact_details", params: { submission_token: token, email_address: 'parcel-test@example.com' }
        follow_redirect!
        expect(response).to have_http_status(:ok)
        expect(document).to have_text('Item sent by post or in personal baggage')
        expect(document).to have_text('Please explain the charge on this parcel.')

        allow(EnquiryForm).to receive(:create!).and_return('resource_id' => 'TEST123')
        post "#{prefix}/enquiry_form/submit", params: { submission_token: token }
        expect(response).to redirect_to("#{prefix}/enquiry_form/confirmation")
        expect(EnquiryForm).to have_received(:create!).with(hash_including(
                                                              enquiry_category: 'Item sent by post or in personal baggage',
                                                              search_request_id: 'search-123',
                                                            ))
      end

      it 'starts with the new origin when opening a different guidance enquiry' do
        get details_path, params: { parcel_gift_step: step.id }
        token = document.find('input[name="submission_token"]', visible: :all)[:value]
        post details_path, params: { submission_token: token, item: 'Book' }

        other_step = journey.steps.last
        get details_path, params: { parcel_gift_step: other_step.id }

        expect(document).to have_link('Back', href: "#{prefix}/#{journey.base_path}/#{other_step.path}")
        expect(document.find_field('What is the item?').value).to be_blank
      end

      it 'starts a new draft when the same guidance page arrives with another request id' do
        get details_path, params: { parcel_gift_step: step.id, request_id: 'search-123' }
        token = document.find('input[name="submission_token"]', visible: :all)[:value]
        post details_path, params: { submission_token: token, item: 'Book' }

        get details_path, params: { parcel_gift_step: step.id, request_id: 'search-456' }
        new_token = document.find('input[name="submission_token"]', visible: :all)[:value]

        expect(new_token).not_to eq(token)
        expect(document.find_field('What is the item?').value).to be_blank

        post details_path, params: {
          submission_token: new_token,
          postal_or_baggage: 'sent_by_post',
          item: 'Book',
          purchase_price: '40',
          query: 'Please explain the charge on this parcel.',
        }
        follow_redirect!
        post "#{prefix}/enquiry_form/contact_details", params: { submission_token: new_token, email_address: 'parcel-test@example.com' }
        follow_redirect!
        allow(EnquiryForm).to receive(:create!).and_return('resource_id' => 'TEST456')
        post "#{prefix}/enquiry_form/submit", params: { submission_token: new_token }

        expect(EnquiryForm).to have_received(:create!).with(hash_including(search_request_id: 'search-456'))
      end

      it 'keeps the draft and its search context when no usable request id arrives' do
        get details_path, params: { parcel_gift_step: step.id, request_id: 'search-123' }
        token = document.find('input[name="submission_token"]', visible: :all)[:value]
        post details_path, params: { submission_token: token, item: 'Book' }

        get details_path, params: { parcel_gift_step: step.id, request_id: 'x' * 65 }

        expect(document.find('input[name="submission_token"]', visible: :all)[:value]).to eq(token)
        expect(document.find_field('What is the item?').value).to eq('Book')
      end

      it 'retains the normal enquiry Back link after starting an ordinary enquiry' do
        get details_path, params: { parcel_gift_step: step.id }
        get "#{prefix}/enquiry_form"
        token = document.find('input[name="submission_token"]', visible: :all)[:value]
        post "#{prefix}/enquiry_form/category", params: { submission_token: token, category: 'import_duties_and_quota' }
        post "#{prefix}/enquiry_form/enquiry_type", params: { submission_token: token, enquiry_type: 'postal_or_baggage' }
        follow_redirect!

        expect(document).to have_link('Back', href: "#{prefix}/enquiry_form/enquiry_type")
        expect(document).not_to have_link('Back', href: guidance_path)
      end

      [nil, 'unknown', 'https://example.com', { route_name: 'parcel_gift_charges' }].each do |origin|
        it "does not start a deep-linked draft with invalid origin #{origin.inspect}" do
          get details_path, params: { parcel_gift_step: origin }
          expect(response).to redirect_to("#{prefix}/enquiry_form")
        end
      end

      it 'does not enable deep entry when the parcel feature is off' do
        disable_feature(:parcel_gift_journey)
        get details_path, params: { parcel_gift_step: step.id }
        expect(response).to redirect_to("#{prefix}/enquiry_form")
      end

      it 'rejects an origin unavailable in the current service' do
        raw = YAML.safe_load_file(Rails.root.join('config/parcel_gift_journey.yml'))
        raw['steps'].first['services'] = [service == 'uk' ? 'xi' : 'uk']
        restricted = TradeTariffFrontend::ParcelGiftJourney.new(raw, service_names: %w[uk xi])
        allow(Rails.configuration).to receive(:parcel_gift_journey).and_return(restricted)

        get details_path, params: { parcel_gift_step: step.id }
        expect(response).to redirect_to("#{prefix}/enquiry_form")
      end
    end
  end

  def document
    Capybara.string(response.body)
  end
end
