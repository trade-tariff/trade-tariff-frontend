require 'spec_helper'

RSpec.feature 'Cookies management' do
  scenario 'accepting cookies from banner' do
    visit help_path

    expect(page).to have_css 'h1', text: 'Help on using the tariff'
    expect(page).to have_css '.govuk-cookie-banner', text: /We use some essential cookies/
    click_on 'Accept additional cookies'

    expect(page).to have_css 'h1', text: 'Help on using the tariff'
    expect(page).not_to have_css '.govuk-cookie-banner', text: /We use some essential cookies/
    expect(page).to have_css '#cookies_accepted'
    click_on 'Hide this message'

    expect(page).not_to have_css 'govuk-cookie-banner'
    expect(page).to have_css 'h1', text: 'Help on using the tariff'
  end

  scenario 'rejecting cookies from banner' do
    visit help_path

    expect(page).to have_css 'h1', text: 'Help on using the tariff'
    expect(page).to have_css '.govuk-cookie-banner', text: /We use some essential cookies/
    click_on 'Reject additional cookies'

    expect(page).to have_css 'h1', text: 'Help on using the tariff'
    expect(page).not_to have_css '.govuk-cookie-banner', text: /We use some essential cookies/
    expect(page).to have_css '#cookies_rejected'
    click_on 'Hide this message'

    expect(page).not_to have_css 'govuk-cookie-banner'
    expect(page).to have_css 'h1', text: 'Help on using the tariff'
  end

  scenario 'manually setting cookies' do
    visit help_path

    expect(page).to have_css 'h1', text: 'Help on using the tariff'
    expect(page).to have_css '.govuk-cookie-banner', text: /We use some essential cookies/
    click_on 'View cookies'

    expect(page).to have_css 'h1', text: 'Cookies on the UK Integrated Online Tariff'
    expect(page).to have_css '.govuk-cookie-banner', text: /We use some essential cookies/
    expect(page).not_to have_css '.govuk-notification-banner'
    choose 'Use cookies that measure my website use'
    click_on 'Save Changes'

    expect(page).to have_css 'h1', text: 'Cookies on the UK Integrated Online Tariff'
    expect(page).to have_css '.govuk-notification-banner h3', text: 'Your cookie settings were saved'
    expect(page).to have_css '#cookies_accepted'
    click_on 'Hide this message'

    expect(page).to have_css 'h1', text: 'Cookies on the UK Integrated Online Tariff'
    expect(page).not_to have_css '.govuk-notification-banner'
    expect(page).not_to have_css 'govuk-cookie-banner'

    choose 'No, do not use cookies that measure my website use'
    choose 'Yes, use cookies that remember my settings on the site'
    click_on 'Save Changes'

    expect(page).to have_css 'h1', text: 'Cookies on the UK Integrated Online Tariff'
    expect(page).to have_css '.govuk-notification-banner h3', text: 'Your cookie settings were saved'
  end
end
