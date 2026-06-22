require 'spec_helper'

RSpec.describe 'Enquiry Form Entry', :aggregate_failures, type: :feature do
  it 'allows a user to change an answer before submitting' do
    allow(EnquiryForm).to receive(:create!)
      .and_return({ 'resource_id' => 'R1M5X8LU' })

    complete_generic_enquiry(email: 'first@example.com')

    click_link 'Change', href: '/enquiry_form/contact_details?editing=true'

    expect(page).to have_css 'h1', text: 'Contact details'
    fill_in 'Email address', with: 'updated@example.com'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Check your answers before submitting your form'
    expect(page).to have_content 'updated@example.com'

    click_button 'Submit'

    expect(page).to have_css 'h1', text: 'Your request has been submitted'
    expect(page).to have_content 'R1M5X8LU'
  end

  it 'preserves the enquiry when the API submission fails' do
    allow(EnquiryForm).to receive(:create!)
      .and_return({ 'resource_id' => nil })

    complete_generic_enquiry(email: 'trader@example.com')
    click_button 'Submit'

    expect(page).to have_css 'h1', text: 'Check your answers before submitting your form'
    expect(page).to have_content 'There was a problem submitting your enquiry. Please try again later.'
    expect(page).to have_content 'trader@example.com'
    expect(page).to have_content 'I need help understanding tariff quota duties.'
  end

  def complete_generic_enquiry(email:)
    visit product_experience_enquiry_form_path

    choose 'Valuation'
    click_button 'Continue'

    fill_in 'How can we help you?', with: 'I need help understanding tariff quota duties.'
    click_button 'Continue'

    fill_in 'Email address', with: email
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Check your answers before submitting your form'
  end
end
