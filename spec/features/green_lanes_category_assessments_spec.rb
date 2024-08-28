require 'spec_helper'

RSpec.describe 'Green lanes category assessments',
               vcr: {
                 cassette_name: 'green_lanes#wizard',
                 record: :new_episodes,
               },
               js: true do
  scenario 'direct to category 1' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')
    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '6912002310'

    select 'United States (US)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1', with: '2024'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Category 1')
  end

  scenario 'direct to category 2' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')
    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '2402209000'

    select 'Morocco (MA)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1', with: '2024'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Category 2')
  end

  scenario 'direct to category 3' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')
    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '3926200000'

    select 'Bangladesh (BD)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1', with: '2024'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Standard Category')
  end

  scenario 'Given the commodity has Cat1 exemptions \
            when Cat1 exemptions do not apply \
            it results in Category 1' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')
    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '0808108090'

    select 'Ukraine (UA)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1', with: '2024'

    click_on 'Continue'

    check 'exemptions-category-assessment-a6b633a7b098132ec45c036d0e14713a-none-field'
    check 'exemptions-category-assessment-18fcbb5b75781f8a676bd84dae9c170e-none-field'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'
  end

  scenario 'Given the commodity has Cat1 exemptions \
            when Cat1 exemptions apply \
            it results in Category 3' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')
    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '0808108090'

    select 'Ukraine (UA)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1', with: '2024'

    click_on 'Continue'

    expect(page).to have_text('Your goods may be Category 1')

    check 'exemptions-category-assessment-a6b633a7b098132ec45c036d0e14713a-y997-field'
    check 'exemptions-category-assessment-18fcbb5b75781f8a676bd84dae9c170e-y984-field'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Standard Category')
  end

  scenario 'Given the commodity has Cat1 exemptions and does not have Cat2 exemptions, \
            When exemptions apply to Cat1 \
            Then it results in Category 2' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')
    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '2204101500'

    select 'Ukraine (UA)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1', with: '2024'

    click_on 'Continue'

    expect(page).to have_text('Your goods may be Category 1')

    check 'exemptions-category-assessment-a6b633a7b098132ec45c036d0e14713a-y997-field'
    check 'exemptions-category-assessment-18fcbb5b75781f8a676bd84dae9c170e-y984-field'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Category 2')
  end

  scenario 'Given the commodity has both Cat1 and Cat2 exemptions \
            when exemptions for Cat1 apply and \
            exemptions for Cat2 do not apply \
            it results in Category 2' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')

    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '3926909790'

    select 'Iran, Islamic Republic of (IR)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1', with: '2024'

    click_on 'Continue'

    expect(page).to have_text('Your goods may be Category 1')

    check 'exemptions-category-assessment-b75355747789bdbc8e3d63cf2d91d214-y160-field'
    check 'exemptions-category-assessment-e562118c58fdbb9ac68bb82c4593f98e-y966-field'

    click_on 'Continue'

    expect(page).to have_text('Your goods may be Category 2')

    check 'exemptions-category-assessment-b8e061e4ddb9e4d99cbec41195277304-none-field'
    check 'exemptions-category-assessment-34aad1bc2c330cd7635ef3fdacef2de7-none-field'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Category 2')
  end

  scenario 'Given the commodity has Cat1 and Cat2 exemptions \
            when exemptions for Cat1 and Cat2 apply \
            it results in Category 3' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')

    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '3926909790'

    select 'Iran, Islamic Republic of (IR)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1', with: '2024'

    click_on 'Continue'

    expect(page).to have_text('Your goods may be Category 1')

    check 'exemptions-category-assessment-b75355747789bdbc8e3d63cf2d91d214-y160-field'
    check 'exemptions-category-assessment-e562118c58fdbb9ac68bb82c4593f98e-y966-field'

    click_on 'Continue'

    expect(page).to have_text('Your goods may be Category 2')

    check 'exemptions-category-assessment-b8e061e4ddb9e4d99cbec41195277304-y058-field'
    check 'exemptions-category-assessment-34aad1bc2c330cd7635ef3fdacef2de7-y904-field'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Standard Category')
  end

  scenario 'Given the commodity has only Cat2 exemptions \
            when exemptions for Cat2 does not apply \
            then it results in Category 2' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')

    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '1602509590'

    select 'Greenland (GL)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1', with: '2024'

    click_on 'Continue'

    expect(page).to have_text('Your goods may be Category 2')

    check 'exemptions-category-assessment-37f58c7ec2982bf82ab238d33b376b4f-none-field'
    check 'exemptions-category-assessment-abed84f406002f0d36f8660d9f80884e-none-field'
    check 'exemptions-category-assessment-5667f4515c310042a7349c3aa31bd57e-none-field'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Category 2')
  end

  scenario 'Given the commodity has only Cat2 exemptions \
            when exemptions for Cat2 apply \
            then it results in Category 3' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')

    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '1602509590'

    select 'Greenland (GL)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1', with: '2024'

    click_on 'Continue'

    expect(page).to have_text('Your goods may be Category 2')

    check 'exemptions-category-assessment-37f58c7ec2982bf82ab238d33b376b4f-y170-field'
    check 'exemptions-category-assessment-abed84f406002f0d36f8660d9f80884e-y058-field'
    check 'exemptions-category-assessment-5667f4515c310042a7349c3aa31bd57e-y900-field'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Standard Category')
  end
end
