require 'spec_helper'

RSpec.describe 'Duty calculator import destination', :js, type: :feature do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

  before do
    allow(DutyCalculator::UserSession).to receive_messages(build: user_session, build_from_params: user_session, get: user_session)
  end

  it 'shows the expected page title and form copy on the step page' do
    visit import_destination_path

    expect(page).to have_css('h1', text: 'Which part of the UK are you importing into?')
    expect(page).to have_title('Which part of the UK are you importing into - Online Tariff Duty calculator')
    expect(page).to have_css('.govuk-hint', text: 'The duty you are charged may be dependent on the part of the UK to which you are importing.')
    expect(page).to have_field('England, Scotland or Wales (GB)')
    expect(page).to have_field('Northern Ireland')
  end

  it 'shows an error summary when the form is submitted without a choice' do
    visit import_destination_path
    click_button 'Continue'

    expect(page).to have_css('.govuk-error-summary')
    expect(page).to have_css('.govuk-error-summary__list', text: 'Select a destination')
    expect(page).to have_title('Which part of the UK are you importing into - Online Tariff Duty calculator')
  end
end
