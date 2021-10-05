require 'spec_helper'

RSpec.describe 'Date & Currency change', js: true, vcr: {
  cassette_name: 'date_currency',
  record: :once,
  match_requests_on: %i[path query],
} do
  it 'displays the current date' do
    visit sections_path(day: 0o1, month: 0o2, year: 2019)

    expect(page).to have_content 'This tariff is for 1 February 2019'
  end

  it 'is able to change dates and go back in time' do
    visit sections_path(day: 0o1, month: 0o2, year: 2019)

    expect(page).to have_content 'This tariff is for 1 February 2019'
    expect(page).to have_content 'Change date'

    click_link 'Change date'

    expect(page).to have_content 'Set date'

    page.execute_script("$('#tariff_date_year').val('2018')")
    page.execute_script("$('#tariff_date_month').val('12')")

    click_button 'Set date'

    expect(page).to have_content 'This tariff is for 1 December 2018'
    expect(page).to have_content 'Change date'
  end

  it 'displays the searched-for date, if the searched-for date is past BREXIT_DATE, and the current date is past BREXIT_DATE' do
    post_eu_exit_date = DateTime.new(2021, 1, 2, 12, 0, 0)
    searched_for_date = DateTime.new(2021, 2, 2, 12, 0, 0)

    Timecop.freeze(post_eu_exit_date) do
      visit sections_path

      click_link 'Change date'

      page.execute_script("$('#tariff_date_year').val('#{searched_for_date.year}')")
      page.execute_script("$('#tariff_date_month').val('#{searched_for_date.month}')")
      page.execute_script("$('#tariff_date_day').val('#{searched_for_date.day}')")

      click_button 'Set date'

      expect(page).to have_content "This tariff is for #{searched_for_date.strftime('%-d %B %Y')}"
    end
  end
end
