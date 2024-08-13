require 'spec_helper'

RSpec.describe 'Green lanes category assessments',
               vcr: {
                 cassette_name: 'green_lanes#wizard',
                 record: :new_episodes,
               },
               js: true do
  # 1 - direct to cat 1 (no exemptions) "6912002310", "USA"
  # 2 - direct to cat 2 (no exemptions) "2204101500", "Italy"
  # 3 - direct to cat 3 "0808108090", "Chile"
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

    fill_in 'green_lanes_moving_requirements_form_moving_date_3i', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2i', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1i', with: '2024'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Category 1')
  end

  scenario 'direct to category 2' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')
    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '2204101500'

    select 'Italy (IT)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3i', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2i', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1i', with: '2024'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Category 2')
  end

  scenario 'direct to category 3' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')
    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '0808108090'

    select 'Chile (CL)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3i', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2i', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1i', with: '2024'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Standard Category')
  end

  scenario 'category 1 with exemptions, exemptions do not apply resulting in category 1' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')
    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '0808108090'

    select 'Ukraine (UA)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3i', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2i', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1i', with: '2024'

    click_on 'Continue'

    check 'exemptions-category-assessment-34-none-field'
    check 'exemptions-category-assessment-82-none-field'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Category 1')
  end

  scenario 'category 1 with exemptions, exemptions apply resulting in category 3' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')
    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '0808108090'

    select 'Ukraine (UA)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3i', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2i', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1i', with: '2024'

    click_on 'Continue'

    check 'exemptions-category-assessment-34-y997-field'
    check 'exemptions-category-assessment-82-y984-field'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Standard Category')
  end

  scenario 'category 1 with exemptions, \
          category 2 without exemptions, \
          exemptions apply to category 1 \
          resulting in category 2' do
    visit new_green_lanes_moving_requirements_path

    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')
    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '2204101500'

    select 'Ukraine (UA)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

    fill_in 'green_lanes_moving_requirements_form_moving_date_3i', with: '12'
    fill_in 'green_lanes_moving_requirements_form_moving_date_2i', with: '8'
    fill_in 'green_lanes_moving_requirements_form_moving_date_1i', with: '2024'

    click_on 'Continue'

    check 'exemptions-category-assessment-34-y997-field'
    check 'exemptions-category-assessment-82-y984-field'

    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    click_on 'Continue'

    expect(page).to have_css('h1', text: 'Category 2')
  end
  #   scenario 'Category 1' do
  #     visit new_green_lanes_moving_requirements_path

  #     expect(page).to have_selector('#new_green_lanes_moving_requirements_form')
  #     fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: '4114109000'

  #     select 'Ukraine (UA)', from: 'green-lanes-moving-requirements-form-country-of-origin-field'

  #     fill_in 'green_lanes_moving_requirements_form_moving_date_3i', with: '12'
  #     fill_in 'green_lanes_moving_requirements_form_moving_date_2i', with: '8'
  #     fill_in 'green_lanes_moving_requirements_form_moving_date_1i', with: '2024'

  #     click_on 'Continue'

  #     check 'exemptions-category-assessment-34-none-field'
  #     check 'exemptions-category-assessment-82-none-field'

  #     click_on 'Continue'

  #     # Confirm answers are okay
  #     click_on 'Continue'

  #     expect(page).to have_css('h1', text: 'Category 1')
  #   end
  # [category_1_with_exemptions, category_2_with_exemptions] # pick some for category 1 and none for category 2
  # [category_1_with_exemptions, category_2_with_exemptions] # pick all for category 1 and all for category 2
end
