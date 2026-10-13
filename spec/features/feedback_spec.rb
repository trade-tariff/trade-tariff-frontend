require 'spec_helper'

RSpec.feature 'Feedback', type: :feature do
  before do
    ActionController::Base.allow_forgery_protection = true
  end

  after do
    ActionController::Base.allow_forgery_protection = false
  end

  scenario 'with original page URL' do
    visit '/404'
    expect(page).to have_css 'h1', text: 'Page not found'

    click_on 'Feedback'
    expect(page).to have_css 'h1', text: 'Give feedback on Online Trade Tariff'
    expect(page).to have_field 'Tell us how to improve our service'
    expect(page).to have_text 'Feedback is anonymous. Do not include any personal information.'
    expect(page).to have_css '.govuk-character-count'
    expect(page).to have_css 'h2', text: 'Need help with something?'
    expect(page).to have_link 'enquiry form'
    fill_in 'feedback[message]', with: 'Some random feedback'
    click_button 'Submit feedback'

    expect(page).to have_css 'h1', text: 'Feedback submitted'
    expect(page).to have_css 'a', text: 'Return to page'
    expect(page).to have_link nil, href: /404/
  end

  scenario 'when original page is feedback page' do
    visit feedback_path
    expect(page).to have_css 'h1', text: 'Give feedback on Online Trade Tariff'
    fill_in 'feedback[message]', with: 'Some random feedback'
    click_button 'Submit feedback'

    expect(page).to have_css 'h1', text: 'Feedback submitted'
    expect(page).not_to have_css 'a', text: 'Return to page'
  end

  scenario 'feedback bottom banner is not shown on feedback page' do
    visit '/404'
    expect(page).to have_css 'h2.govuk-feedback__title', text: 'Help us improve this service'
    expect(page).to have_text 'Tell us about your experience using this service.'
    expect(page).to have_link 'Give us your feedback'

    click_on 'Give us your feedback'
    expect(page).to have_css 'h1', text: 'Give feedback on Online Trade Tariff'
  end

  scenario 'feedback banner is not shown on feedback page' do
    visit '/404'
    expect(page).to have_css 'a', exact_text: 'feedback'
    expect(page).to have_text 'We’re making improvements to this service. Let us know what you think by giving your feedback.'

    click_on 'feedback'
    expect(page).not_to have_css 'a', exact_text: 'feedback'
    expect(page).not_to have_text 'We’re making improvements to this service. Let us know what you think by giving your feedback.'
  end
end
