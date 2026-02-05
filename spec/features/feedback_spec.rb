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
    expect(page).to have_css 'a', text: 'Share your feedback'
    expect(page).to have_css 'p', text: 'Give feedback about this service'
    expect(page).to have_text 'Tell us about your experience using this service to help us improve it.'

    click_on 'Feedback'
    expect(page).not_to have_css '.feedback-useful-banner'
    expect(page).not_to have_css 'a', text: 'Share your feedback'
  end

  scenario 'feedback banner is not shown on feedback page' do
    visit '/404'
    expect(page).to have_css 'a', text: 'give your feedback (opens in new tab)'
    expect(page).to have_text 'Help us improve this service'

    click_on 'Feedback'
    expect(page).not_to have_css '.tariff-feedback-banner'
    expect(page).not_to have_css 'a', text: 'give your feedback (opens in new tab)'
  end
end
