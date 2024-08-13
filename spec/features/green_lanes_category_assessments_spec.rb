require 'spec_helper'

RSpec.describe 'Green lanes category assessments', vcr: { cassette_name: 'green_lanes_category_assessments', record: :new_episodes } do
  before do
    TradeTariffFrontend::ServiceChooser.service_choice = 'xi'
  end

  scenario 'Category 1' do
    visit '/green_lanes/moving_requirements/new'
    binding.pry

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')

    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '4114109000'

    select 'Ukraine (UA)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3i', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2i', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1i', with: '2024'

    click_on 'Continue'

    expect(page).to have_content('We need more information about your goods')


    # expect(page).to have_css 'h1', text: 'Give feedback on Online Trade Tariff'
    # fill_in 'feedback[message]', with: 'Some random feedback'
    # click_button 'Submit feedback'

    # expect(page).to have_css 'h1', text: 'Feedback submitted'
    # expect(page).to have_css 'a', text: 'Return to page'
    # expect(page).to have_link nil, href: /404/
  end
end
