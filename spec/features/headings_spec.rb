require 'spec_helper'

RSpec.describe 'JS behaviour', :js, vcr: { cassette_name: 'headings#8501' } do
  it 'render table tools on the top and bottom' do
    visit heading_path('8501')

    find(:button, 'Accept additional cookies', visible: true).click
    find(:button, 'Hide this message', visible: true).click

    expect(page).to have_content('Choose the commodity code that best matches your goods to see more information')
    expect(page).to have_content('Headings in the tariff are closed to help you navigate')
    expect(page.find_all('.tree-controls').length).to eq(2)

    # Verify nodes are closed by default
    expect(page.find_all('.has_children')).to \
      all(have_xpath("//ul[@class='govuk-list' and @aria-hidden='true']"))

    # Expand all nodes
    page.find_all('.tree-controls')[0].find('a:nth-child(1)').click

    expect(page.find_all(".has_children ul[aria-hidden='false']", wait: false).length).to be > 0

    # Collapse all nodes
    page.find_all('.tree-controls')[1].find('a:nth-child(2)').click

    expect(page.find_all(".has_children ul[aria-hidden='true']", wait: false).length).to be > 0
  end

  it 'is able to open close specific headings' do
    visit heading_path('8501')

    find(:button, 'Accept additional cookies', visible: true).click
    find(:button, 'Hide this message', visible: true).click

    # Verify nodes start closed
    parent = page.first('.has_children')
    expect(parent).to have_xpath("./ul[contains(concat(' ',normalize-space(@class),' '), ' govuk-list ') and @aria-hidden='true']")

    within parent do
      # Click to expand (only immediate children, non-recursive)
      find(:xpath, "./span[contains(concat(' ',normalize-space(@class),' '), ' description ')]").click
      expect(parent.find_all(:xpath, "./span[contains(concat(' ',normalize-space(@class),' '), ' open ')]", wait: false).length).to eq(1)
      expect(parent.find(:xpath, "./ul[@class='govuk-list']")['aria-hidden']).to eq('false')

      # Click again to collapse
      find(:xpath, "./span[contains(concat(' ',normalize-space(@class),' '), ' description ')]").click
      expect(parent.find_all(:xpath, "./span[contains(concat(' ',normalize-space(@class),' '), ' open ')]", wait: false).length).to eq(0)
      expect(parent.find(:xpath, "./ul[@class='govuk-list']")['aria-hidden']).to eq('true')
    end
  end
end
