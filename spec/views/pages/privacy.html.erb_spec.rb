require 'spec_helper'

RSpec.describe 'pages/privacy', type: :view do
  subject(:rendered_page) { render && rendered }

  include_context 'with UK service'

  it 'describes the data processed for the Developer Portal service' do
    paragraph = Capybara.string(rendered_page).find('p', text: 'For the Developer Portal service:')
    list = paragraph.find(:xpath, 'following-sibling::ul[1]')

    expect(list).to have_css('li', text: 'email address', count: 1)
  end
end
