require 'spec_helper'

RSpec.feature 'Cookies management', js: true do
  scenario 'accepting cookies from banner' do
    visit help_path

    expect(page).to have_css 'h1', text: 'Help on using the tariff'
    expect(page).to have_css '#banner', text: /We use some essential cookies/
    find(:button, 'Accept additional cookies', visible: true).click
    expect(page).to have_css 'h1', text: 'Help on using the tariff'
    find(:button, 'Hide this message', visible: true).click
    expect(page).to have_css '#banner', visible: :hidden
  end

  scenario 'rejecting cookies from banner' do
    visit help_path

    expect(page).to have_css 'h1', text: 'Help on using the tariff'
    expect(page).to have_css '#banner', text: /We use some essential cookies/
    find(:button, 'Reject additional cookies', visible: true).click
    expect(page).to have_css 'h1', text: 'Help on using the tariff'
    find(:button, 'Hide this message', visible: true).click
    expect(page).to have_css '#banner', visible: :hidden
  end

  scenario 'manually setting cookies' do
    visit help_path

    expect(page).to have_css 'h1', text: 'Help on using the tariff'
    expect(page).to have_css '#banner', text: /We use some essential cookies/
    find(:link, 'View cookies', visible: true).click

    expect(page).to have_css 'h1', text: 'Cookies on the UK Integrated Online Tariff'
    expect(page).to have_css '#banner', text: /We use some essential cookies/
    choose 'No, do not use cookies that measure my website use'
    choose 'Yes, use cookies that remember my settings on the site'
    choose 'Use cookies that measure my website use'
    click_on 'Save Changes'
    expect(page).to have_css '.govuk-notification-banner h3', text: 'Your cookie settings were saved'
    expect(page).to have_css '#cookies_accepted'

    find(:button, 'Accept additional cookies', visible: true).click
    find(:button, 'Hide this message', visible: true).click

    expect(page).to have_css 'h1', text: 'Cookies on the UK Integrated Online Tariff'
    expect(page).to have_css '#banner', visible: :hidden
  end
end
