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
    expect(page).to have_css 'a', text: 'Yes'
    expect(page).to have_css 'a', text: 'No'
    expect(page).to have_css 'a', text: 'Report a problem with this page'
    expect(page).to have_css 'p', text: 'Is this page useful?'

    click_on 'Yes'
    expect(page).not_to have_css 'a', text: 'Yes'
    expect(page).not_to have_css 'a', text: 'No'
    expect(page).not_to have_css 'a', text: 'Report a problem with this page'
    expect(page).not_to have_css 'p', text: 'Is this page useful?'
  end

  scenario 'feedback banner is not shown on feedback page' do
    visit '/404'
    expect(page).to have_css 'a', exact_text: 'feedback'
    expect(page).to have_css 'p', text: 'Tell us what you think - your feedback will help us improve.'

    click_on 'feedback'
    expect(page).not_to have_css 'a', exact_text: 'feedback'
    expect(page).not_to have_css 'p', text: 'Tell us what you think - your feedback will help us improve.'
  end
end
