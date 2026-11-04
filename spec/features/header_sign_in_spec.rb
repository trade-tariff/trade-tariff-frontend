require 'spec_helper'

RSpec.feature 'Header sign-in link', type: :feature do
  let(:id_token_cookie_name) { TradeTariffFrontend.id_token_cookie_name }

  def visit_page(path = help_path)
    visit path
  end

  def sign_in
    visit_page
    page.driver.browser.set_cookie("#{id_token_cookie_name}=active-token")
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
    allow(User).to receive(:find).and_return(build(:user))

    sign_in
    visit_page(myott_path)

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

  context 'with responsive navigation', :js do
    def resize_to(width)
      page.current_window.resize_to(width, 800)
      page.evaluate_script('window.dispatchEvent(new Event("resize"))')
    end

    it 'keeps the account link in the mobile navigation' do
      visit_page
      resize_to(320)

      expect(page).not_to have_link('Sign in', href: '/subscriptions/start', visible: :visible)
      expect(page).not_to have_link('Search', visible: :visible)

      find('.govuk-service-navigation__toggle').click

      expect(page).to have_link('Sign in', href: '/subscriptions/start', visible: :visible)
      expect(page).to have_link('Search', visible: :visible)
    end

    it 'keeps the account link visible at tablet width and with enlarged text' do
      visit_page
      resize_to(768)
      expect(page).to have_link('Sign in', href: '/subscriptions/start', visible: :visible)

      page.execute_script("document.documentElement.style.fontSize = '200%'")

      expect(page).to have_link('Sign in', href: '/subscriptions/start', visible: :visible)
    end
  end
end
