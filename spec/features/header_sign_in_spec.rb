require 'spec_helper'

RSpec.feature 'Header sign-in link', type: :feature do
  let(:id_token_cookie_name) { TradeTariffFrontend.id_token_cookie_name }

  def visit_page
    visit help_path
  end

  def sign_in
    page.driver.browser.set_cookie("#{id_token_cookie_name}=test-token")
  end

  def sign_out
    page.driver.browser.clear_cookies
  end

  scenario 'takes a signed-out user to the subscriptions start page' do
    visit_page

    expect(page).to have_link('Sign in', href: '/subscriptions/start')

    click_link 'Sign in'

    expect(page).to have_current_path('/subscriptions/start')
  end

  scenario 'takes a signed-in user to subscriptions' do
    sign_in
    visit_page

    expect(page).to have_link('Sign in', href: '/subscriptions')
  end

  scenario 'returns to the sign-in destination after signing out' do
    sign_in
    visit_page
    expect(page).to have_link('Sign in', href: '/subscriptions')

    sign_out
    visit_page

    expect(page).to have_link('Sign in', href: '/subscriptions/start')
  end
end
