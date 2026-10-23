require 'spec_helper'

RSpec.describe 'Cookies policy', type: :request do
  describe 'GET /cookies/policy' do
    before { get cookies_policy_path }

    it 'lists the commodity search preference cookie' do
      page = Capybara.string(response.body)

      expect(page.find('tr', text: 'commodity_search_open').text).to include(
        'Search for another commodity',
        '28 days',
      )
    end

    it 'lists the commodity hierarchy preference cookie' do
      page = Capybara.string(response.body)

      expect(page.find('tr', text: 'commodity_hierarchy_open').text).to include(
        'View Section, Chapter, Heading...',
        '28 days',
      )
    end
  end
end
