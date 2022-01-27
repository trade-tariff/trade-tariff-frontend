require 'spec_helper'

RSpec.describe 'JS behaviour', js: true, vcr: { cassette_name: 'headings#8501' } do
  it 'render table tools on the top and bottom' do
    visit heading_path('8501')

    expect(page).to have_content('Choose the commodity code that best matches your goods to see more information')
    expect(page.find_all('.tree-controls').length).to eq(2)

    expect(page.find_all('.has_children')).to \
      all(have_xpath("//ul[@class='govuk-list' and @aria-hidden='true']"))

    page.find_all('.tree-controls')[0].first('a').click

    expect(page.find_all(".has_children ul[aria-hidden='true']").length).to eq(0)

    page.find_all('.tree-controls')[1].find('a:nth-child(2)').click

    expect(page.find_all(".has_children ul[aria-hidden='false']").length).to eq(0)
  end

  it 'is able to open close specific headings' do
    visit heading_path('8501')

    page.find_all('.tree-controls')[1].find('a:nth-child(2)').click

    parent = page.first('.has_children')
    expect(parent).to have_xpath("./ul[contains(concat(' ',normalize-space(@class),' '), ' govuk-list ')]")

    within parent do
      find(:xpath, "./span[contains(concat(' ',normalize-space(@class),' '), ' description ')]").click
      expect(parent.find_all(:xpath, "./span[contains(concat(' ',normalize-space(@class),' '), ' open ')]").length).to eq(1)

      find(:xpath, "./span[contains(concat(' ',normalize-space(@class),' '), ' description ')]").click
      expect(parent.find_all(:xpath, "./span[contains(concat(' ',normalize-space(@class),' '), ' open ')]").length).to eq(0)
    end
  end
end
