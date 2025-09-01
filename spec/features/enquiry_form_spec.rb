require 'spec_helper'

RSpec.describe 'Enquiry Form Entry', type: :feature do
  include EnquiryFormHelpers
  around do |example|
    old_store = Rails.cache
    # implementing a memory store for this test (globally doing this breaks other tests)
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    # restore the original store
    Rails.cache = old_store
  end

  describe 'new enquiry' do
    context 'when user enters valid data' do
      before do
        allow(EnquiryForm).to receive(:create!)
          .and_return({ 'resource_id' => 'R1M5X8LU' })
      end

      it 'allows a user to complete the enquiry form' do
        start_enquiry
        fill_in_full_name
        fill_in_company_name
        fill_in_job_title
        fill_in_email
        choose_category
        fill_in_query
        expect(page).to have_css 'h1', text: 'Check your answers before submitting your form'
        within('.govuk-summary-list__row', text: 'Full name') do
          expect(page).to have_css('.govuk-summary-list__value', text: 'John Doe')
        end
        within('.govuk-summary-list__row', text: 'Company name (optional)') do
          expect(page).to have_css('.govuk-summary-list__value', text: 'Acme')
        end
        within('.govuk-summary-list__row', text: 'Job title (optional)') do
          expect(page).to have_css('.govuk-summary-list__value', text: 'Director')
        end
        within('.govuk-summary-list__row', text: 'Email address') do
          expect(page).to have_css('.govuk-summary-list__value', text: 'john.doe@acme.com')
        end
        within('.govuk-summary-list__row', text: 'What do you need help with?') do
          expect(page).to have_css('.govuk-summary-list__value', text: 'Quotas')
        end
        within('.govuk-summary-list__row', text: 'How can we help?') do
          expect(page).to have_css('.govuk-summary-list__value', text: 'I need to know my quotas')
        end
        click_button 'Submit'
        expect(page).to have_css 'h1', text: 'Your form has been submitted'
        expect(page).to have_content('R1M5X8LU')
      end

      it 'allows a user to change a field' do
        start_enquiry
        fill_in_full_name
        fill_in_company_name company: 'My Company'
        fill_in_job_title
        fill_in_email
        choose_category
        fill_in_query
        expect(page).to have_css 'h1', text: 'Check your answers before submitting your form'
        click_link 'Change', href: '/enquiry_form/company_name?editing=true'
        expect(page).to have_field 'Company name', with: 'My Company'
        fill_in 'Company name', with: 'Acme Enterprises'
        click_button 'Continue'
        expect(page).to have_css 'h1', text: 'Check your answers before submitting your form'
        within('.govuk-summary-list__row', text: 'Company name (optional)') do
          expect(page).to have_css('.govuk-summary-list__value', text: 'Acme Enterprises')
        end
        click_button 'Submit'
        expect(page).to have_css 'h1', text: 'Your form has been submitted'
        expect(page).to have_content('R1M5X8LU')
      end
    end

    context 'when full name is missing' do
      before do
        start_enquiry
        fill_in_full_name name: ''
      end

      include_examples 'a validation error', 'Please enter your full name'
    end

    context 'when email address is missing' do
      before do
        start_enquiry
        fill_in_full_name
        fill_in_company_name
        fill_in_job_title
        fill_in_email email: ''
      end

      include_examples 'a validation error', 'Please enter a valid email address'
    end

    context 'when email address is invalid' do
      before do
        start_enquiry
        fill_in_full_name
        fill_in_company_name
        fill_in_job_title
        fill_in_email email: 'a'
      end

      include_examples 'a validation error', 'Please enter a valid email address'
    end

    context 'when category is not selected' do
      before do
        start_enquiry
        fill_in_full_name
        fill_in_company_name
        fill_in_job_title
        fill_in_email
        choose_category category: nil
      end

      include_examples 'a validation error', 'Please select a category'
    end

    context 'when query is missing' do
      before do
        start_enquiry
        fill_in_full_name
        fill_in_company_name
        fill_in_job_title
        fill_in_email
        choose_category
        fill_in_query query: ''
      end

      include_examples 'a validation error', 'Please enter your query'
    end

    context 'when query is > 5000 characters' do
      before do
        start_enquiry
        fill_in_full_name
        fill_in_company_name
        fill_in_job_title
        fill_in_email
        choose_category
        fill_in_query query: 'A' * 5001
      end

      include_examples 'a validation error', 'Please limit your query to 5000 characters or less.'
    end

    context 'when the API doesn\'t return a resource ID' do
      before do
        allow(EnquiryForm).to receive(:create!)
          .and_return({ 'resource_id' => nil })
        start_enquiry
        fill_in_full_name
        fill_in_company_name
        fill_in_job_title
        fill_in_email
        choose_category
        fill_in_query
        click_button 'Submit'
      end

      include_examples 'a validation error', 'There was a problem submitting your enquiry. Please try again later.'
    end
  end
end
