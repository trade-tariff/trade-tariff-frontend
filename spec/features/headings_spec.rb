require 'spec_helper'

RSpec.describe 'JS behaviour', :js, vcr: { cassette_name: 'headings#8501' } do
  it 'render table tools on the top and bottom' do
    visit heading_path('8501')

    find(:button, 'Accept additional cookies', visible: true).click
    find(:button, 'Hide this message', visible: true).click

    expect(page).to have_content('Choose the commodity code that best matches your goods to see more information')
    expect(page.find_all('.tree-controls').length).to eq(2)

    expect(page.find_all('.has_children')).to \
      all(have_xpath("//ul[@class='govuk-list' and @aria-hidden='false']"))

    page.find_all('.tree-controls')[1].first('a').click # hide all

    expect(page.find_all(".has_children ul[aria-hidden='true']", wait: false).length).to eq(0)

    page.find_all('.tree-controls')[0].find('a:nth-child(2)').click # reshow all

    expect(page.find_all(".has_children ul[aria-hidden='false']", wait: false).length).to eq(0)
  end

  it 'is able to open close specific headings' do
    visit heading_path('8501')

    find(:button, 'Accept additional cookies', visible: true).click
    find(:button, 'Hide this message', visible: true).click

    page.find_all('.tree-controls')[1].find('a:nth-child(2)').click

    parent = page.first('.has_children')
    expect(parent).to have_xpath("./ul[contains(concat(' ',normalize-space(@class),' '), ' govuk-list ')]")

    within parent do
      find(:xpath, "./span[contains(concat(' ',normalize-space(@class),' '), ' description ')]").click
      expect(parent.find_all(:xpath, "./span[contains(concat(' ',normalize-space(@class),' '), ' open ')]", wait: false).length).to eq(1)

      find(:xpath, "./span[contains(concat(' ',normalize-space(@class),' '), ' description ')]").click
      expect(parent.find_all(:xpath, "./span[contains(concat(' ',normalize-space(@class),' '), ' open ')]", wait: false).length).to eq(0)
    end
  end
end
