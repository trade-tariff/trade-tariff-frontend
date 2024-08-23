require 'spec_helper'

RSpec.describe 'Green lanes category assessments',
               vcr: {
                 cassette_name: 'green_lanes#wizard',
                 record: :new_episodes,
               },
               js: true do
  # 1 - direct to cat 1 (no exemptions) "6912002310", "USA"
  # 2 - direct to cat 2 (no exemptions) "2402209000", "Italy"
  # 3 - direct to cat 3 "3926200000", "Bangladesh"
  # 4 - cat 1 with exemptions, exemptions don't apply "0808108090" "Ukraine"
  # 5 - 2204101500 Ukraine
  # 6 - 0808108090 Ukraine

  # 7 - 3926909790 Iran
  # 8 - 3926909790 Iran
  # 9 - 1904901000 China
  # 10 - 1904901000 China
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

    check 'exemptions-category-assessment-34-none-field'
    check 'exemptions-category-assessment-82-none-field'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Category 1')
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

    check 'exemptions-category-assessment-34-y997-field'
    check 'exemptions-category-assessment-82-y984-field'

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

    check 'exemptions-category-assessment-34-y997-field'
    check 'exemptions-category-assessment-82-y984-field'

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

    check 'exemptions-category-assessment-838-y160-field'
    check 'exemptions-category-assessment-30-y966-field'

    click_on 'Continue'

    expect(page).to have_text('Your goods may be Category 2')

    check 'exemptions-category-assessment-23-none-field'
    check 'exemptions-category-assessment-92-none-field'

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

    check 'exemptions-category-assessment-838-y160-field'
    check 'exemptions-category-assessment-30-y966-field'

    click_on 'Continue'

    expect(page).to have_text('Your goods may be Category 2')

    check 'exemptions-category-assessment-23-y058-field'
    check 'exemptions-category-assessment-92-y904-field'

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

    # Check the first 'exemptions-category-assessment-23-none-field'
    all('#exemptions-category-assessment-23-none-field').first.set(true)

    # find(:css, 'input[name="exemptions-category-assessment-23-none-field"]:nth-of-type(1)').set(true)

    # This checkbox has the same ID as previouse "none" in a different Cat Assessment
    # TODO: check Back End API
    # check 'exemptions-category-assessment-23-none-field'
    check 'exemptions-category-assessment-818-none-field'

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

    # We check 1 checkbox instead of two because they share the same ID (there is a ticket to solve this)
    all('#exemptions-category-assessment-23-y170-field').first.set(true)
    check 'exemptions-category-assessment-818-y900-field'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Standard Category')
  end
end
