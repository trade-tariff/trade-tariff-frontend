require 'spec_helper'

RSpec.describe 'Green lanes category assessments',
               vcr: {
                 cassette_name: 'green_lanes/wizard',
                 record: :new_episodes,
               },
               js: true do
  let(:date) { { day: '21', month: '10', year: '2024' } }

  let(:commodity_codes) do
    {
      category_1: '6912002310',
      category_2: '2402209000',
      category_3: '3926200000',
      cat1_exemptions: '0808108090',
      cat1_exemptions_no_cat_2_exemptions: '2204101500',
      cat2_exemptions: '1602509590',
      both_exemptions: '3926909790',
    }
  end

  let(:countries) do
    {
      us: 'United States (US)',
      morocco: 'Morocco (MA)',
      bangladesh: 'Bangladesh (BD)',
      ukraine: 'Ukraine (UA)',
      iran: 'Iran, Islamic Republic of (IR)',
      greenland: 'Greenland (GL)',
    }
  end

  # Journey 1
  scenario 'Journey 1: Direct to category 1' do
    fill_moving_requirments_form(commodity_codes[:category_1], countries[:us])
    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)
    expect(page).not_to have_css('govuk-summary-card')
    click_on 'Continue'
    category_1_result_screen
  end

  # Journey 2
  scenario 'Journey 2: Direct to category 2' do
    fill_moving_requirments_form(commodity_codes[:category_2], countries[:morocco])
    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)
    expect(page).not_to have_css('govuk-summary-card')
    click_on 'Continue'
    category_2_result_screen
  end

  # Journey 3
  scenario 'Journey 3: Direct to standard category' do
    fill_moving_requirments_form(commodity_codes[:category_3], countries[:bangladesh])
    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)
    expect(page).not_to have_css('govuk-summary-card')
    click_on 'Continue'
    standard_category_result_screen
  end

  # Journey 4: Cat 1 via Cat 1 failed exemptions only
  scenario 'Given the commodity has Cat1 exemptions when Cat1 exemptions dont apply it results in Category 1' do
    fill_moving_requirments_form(commodity_codes[:cat1_exemptions], countries[:ukraine])

    check 'exemptions-category-assessment-a6b633a7b098132ec45c036d0e14713a-none-field'
    check 'exemptions-category-assessment-18fcbb5b75781f8a676bd84dae9c170e-none-field'
    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    check_your_answers_exemption_card(%w[Y997 Y984], 'Condition not met')

    click_on 'Continue'

    category_1_result_screen

    expect(page).to have_css('p', text: 'Exemptions not met', count: 2)
    expect(page).to have_no_css('p', text: 'Exemption met')
  end

  # Journey 5: Cat 2 after Cat 1 passed exemptions only
  scenario 'Given the commodity has Cat1 exemptions and at least 1 CA without exemptions when Cat1 exemptions apply it results in Category 2' do
    fill_moving_requirments_form(commodity_codes[:cat1_exemptions_no_cat_2_exemptions], countries[:ukraine])

    expect(page).to have_text('Your goods will be Category 1')

    check 'exemptions-category-assessment-a6b633a7b098132ec45c036d0e14713a-y997-field'
    check 'exemptions-category-assessment-18fcbb5b75781f8a676bd84dae9c170e-y984-field'
    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    check_your_answers_exemption_card(%w[Y997 Y984], 'Condition met')

    click_on 'Continue'

    category_2_result_screen

    expect(page).to have_css('h2', text: 'Your goods are exempt from Category 1 because you meet these conditions')
    expect(page).to have_no_css('p', text: 'Exemption met', count: 2)
    expect(page).to have_no_css('p', text: 'Exemptions not met')
  end

  # Journey 6: Cat 3 after Cat 1 passed exemptions only
  scenario 'Given the commodity has Cat1 exemptions and no Cat2 CAs, When exemptions apply to Cat1 Then it results in Category 3' do
    fill_moving_requirments_form(commodity_codes[:cat1_exemptions], countries[:ukraine])

    expect(page).to have_text('Your goods will be Category 1')

    check 'exemptions-category-assessment-a6b633a7b098132ec45c036d0e14713a-y997-field'
    check 'exemptions-category-assessment-18fcbb5b75781f8a676bd84dae9c170e-y984-field'
    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    check_your_answers_exemption_card(%w[Y997 Y984], 'Condition met')

    click_on 'Continue'

    standard_category_result_screen
    expect(page).to have_css('h2', text: 'Your goods are exempt from Category 1 because you meet these conditions')
    expect(page).to have_no_css('h2', text: 'Your goods are exempt from Category 2 because you meet these conditions')
  end

  # Journey 7: Cat 2 via Cat 1 exemptions passed and 2 exemptions failed
  scenario 'Given the commodity has both Cat1 and Cat2 exemptions when exemptions for Cat1 apply and exemptions for Cat2 do not apply it results in Category 2' do
    fill_moving_requirments_form(commodity_codes[:both_exemptions], countries[:iran])

    expect(page).to have_text('Your goods will be Category 1')

    check 'exemptions-category-assessment-b75355747789bdbc8e3d63cf2d91d214-y160-field'
    check 'exemptions-category-assessment-e562118c58fdbb9ac68bb82c4593f98e-y966-field'
    click_on 'Continue'

    expect(page).to have_text('Your goods will be Category 2')

    check 'exemptions-category-assessment-b8e061e4ddb9e4d99cbec41195277304-none-field'
    check 'exemptions-category-assessment-34aad1bc2c330cd7635ef3fdacef2de7-y904-field'
    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    check_your_answers_exemption_card(%w[Y160 Y966 Y904], 'Condition met')
    check_your_answers_exemption_card(%w[Y170 Y171 Y174 Y175 Y176 Y177 Y930 Y058], 'Condition not met')

    click_on 'Continue'

    category_2_result_screen

    expect(page).to have_css('h2', text: 'Your goods are exempt from Category 1 because you meet these conditions')
    expect(page).to have_css('p', text: 'Exemptions not met')
  end

  # Journey 8: Cat 3 via Cat 1 exemptions passed and 2 exemptions passed
  scenario 'Given the commodity has Cat1 and Cat2 exemptions when exemptions for Cat1 and Cat2 apply it results in Category 3' do
    fill_moving_requirments_form(commodity_codes[:both_exemptions], countries[:iran])

    expect(page).to have_text('Your goods will be Category 1')

    check 'exemptions-category-assessment-b75355747789bdbc8e3d63cf2d91d214-y160-field'
    check 'exemptions-category-assessment-e562118c58fdbb9ac68bb82c4593f98e-y966-field'
    click_on 'Continue'

    expect(page).to have_text('Your goods will be Category 2')

    check 'exemptions-category-assessment-b8e061e4ddb9e4d99cbec41195277304-y058-field'
    check 'exemptions-category-assessment-34aad1bc2c330cd7635ef3fdacef2de7-y904-field'
    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    check_your_answers_exemption_card(%w[Y160 Y966 Y058 Y904], 'Condition met')
    check_your_answers_exemption_card(%w[Y170 Y171 Y174 Y175 Y176 Y177 Y930], 'Condition not met')

    click_on 'Continue'

    standard_category_result_screen

    expect(page).to have_css('h2', text: 'Your goods are exempt from Category 1 because you meet these conditions')
    expect(page).to have_css('h2', text: 'Your goods are exempt from Category 2 because you meet these conditions')
    expect(page).to have_no_css('p', text: 'Exemptions not met')

    expect(page).to have_css('.govuk-summary-list__key', text: 'Y160')
    expect(page).to have_css('.govuk-summary-list__key', text: 'Y966')
    expect(page).to have_css('.govuk-summary-list__key', text: 'Y058')
    expect(page).to have_css('.govuk-summary-list__key', text: 'Y904')

    expect(page).to have_no_css('.govuk-summary-list__key', text: 'Y170')
    expect(page).to have_no_css('.govuk-summary-list__key', text: 'Y171')
    expect(page).to have_no_css('.govuk-summary-list__key', text: 'Y174')
    expect(page).to have_no_css('.govuk-summary-list__key', text: 'Y175')
    expect(page).to have_no_css('.govuk-summary-list__key', text: 'Y176')
    expect(page).to have_no_css('.govuk-summary-list__key', text: 'Y177')
    expect(page).to have_no_css('.govuk-summary-list__key', text: 'Y930')
  end

  # Journey 9: Cat 2 via Cat 2 exemptions failed only
  scenario 'Given the commodity has only Cat2 exemptions when exemptions for Cat2 does not apply then it results in Category 2' do
    fill_moving_requirments_form(commodity_codes[:cat2_exemptions], countries[:greenland])

    expect(page).to have_text('Your goods will be Category 2')

    check 'exemptions-category-assessment-37f58c7ec2982bf82ab238d33b376b4f-none-field'
    check 'exemptions-category-assessment-abed84f406002f0d36f8660d9f80884e-none-field'
    check 'exemptions-category-assessment-5667f4515c310042a7349c3aa31bd57e-y900-field'
    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    check_your_answers_exemption_card(%w[Y900], 'Condition met')
    check_your_answers_exemption_card(%w[Y170 Y058 Y171 Y174 Y175 Y176 Y177], 'Condition not met')

    click_on 'Continue'

    category_2_result_screen

    expect(page).to have_css('p', text: 'Exemptions not met', count: 2)
    expect(page).to have_no_css('p', text: 'Exemption met')
  end

  # Journey 10: Cat 3 via Cat 2 exemptions passed only
  scenario 'Given the commodity has only Cat2 exemptions when exemptions for Cat2 apply then it results in Category 3' do
    fill_moving_requirments_form(commodity_codes[:cat2_exemptions], countries[:greenland])

    expect(page).to have_text('Your goods will be Category 2')

    check 'exemptions-category-assessment-37f58c7ec2982bf82ab238d33b376b4f-y170-field'

    check 'exemptions-category-assessment-abed84f406002f0d36f8660d9f80884e-y058-field'
    check 'exemptions-category-assessment-abed84f406002f0d36f8660d9f80884e-y170-field' # This must be checked to pass the ambiguous exemption check

    check 'exemptions-category-assessment-5667f4515c310042a7349c3aa31bd57e-y900-field'
    click_on 'Continue'

    expect(page).to have_current_path(green_lanes_check_your_answers_path, ignore_query: true)

    check_your_answers_exemption_card(%w[Y170 Y058 Y900], 'Condition met')
    check_your_answers_exemption_card(%w[Y171 Y174 Y175 Y176 Y177], 'Condition not met')

    click_on 'Continue'

    standard_category_result_screen

    expect(page).to have_no_css('h2', text: 'Your goods are exempt from Category 1 because you meet these conditions')
    expect(page).to have_css('h2', text: 'Your goods are exempt from Category 2 because you meet these conditions')
    expect(page).to have_no_css('p', text: 'Exemptions not met')

    expect(page).to have_css('.govuk-summary-list__key', text: 'Y170')
    expect(page).to have_css('.govuk-summary-list__key', text: 'Y058')
    expect(page).to have_css('.govuk-summary-list__key', text: 'Y900')

    expect(page).to have_no_css('.govuk-summary-list__key', text: 'Y171')
    expect(page).to have_no_css('.govuk-summary-list__key', text: 'Y174')
    expect(page).to have_no_css('.govuk-summary-list__key', text: 'Y175')
    expect(page).to have_no_css('.govuk-summary-list__key', text: 'Y176')
    expect(page).to have_no_css('.govuk-summary-list__key', text: 'Y177')
  end

  def check_your_answers_exemption_card(codes, exemption_status)
    codes.each do |code|
      within('.govuk-summary-list__row', text: code) do
        expect(page).to have_css('.govuk-summary-list__actions', text: exemption_status)
      end
    end
  end

  def fill_moving_requirments_form(commodity_code, country)
    visit new_green_lanes_moving_requirements_path
    expect(page).to have_selector('#new_green_lanes_moving_requirements_form')

    fill_in 'green-lanes-moving-requirements-form-commodity-code-field', with: commodity_code
    select country, from: 'green-lanes-moving-requirements-form-country-of-origin-field'
    fill_in 'green_lanes_moving_requirements_form_moving_date_3', with: date[:day]
    fill_in 'green_lanes_moving_requirements_form_moving_date_2', with: date[:month]
    fill_in 'green_lanes_moving_requirements_form_moving_date_1', with: date[:year]

    click_on 'Continue'
  end

  def category_1_result_screen
    expect(page).to have_css('h1', text: 'Category 1')
    expect(page).to have_css('.govuk-summary-list__value', text: 'Category 1')

    expect(page).to have_css('h2', text: 'Your Category 1 result is based on EU regulations')
  end

  def category_2_result_screen
    expect(page).to have_css('h1', text: 'Category 2')
    expect(page).to have_css('.govuk-summary-list__value', text: 'Category 2')

    expect(page).to have_css('h2', text: 'Your Category 2 result is based on EU regulations')
  end

  def standard_category_result_screen
    expect(page).to have_css('h1', text: 'Standard goods')
    expect(page).to have_no_css('.govuk-summary-list__value', text: 'Category 1')
    expect(page).to have_no_css('.govuk-summary-list__value', text: 'Category 2')
  end
end
