require 'spec_helper'

RSpec.describe 'news_items/_header_banner', type: :view do
  subject { render 'news_items/header_banner', news_item: news_item }

  let(:news_item) { build :news_item, content: 'Important news for [[SERVICE_NAME]]' }

  it { is_expected.to have_css '.hott-header-banner .govuk-width-container p', count: 1 }
  it { is_expected.to have_css 'p', text: 'Important news for UK' }

  context 'without any news' do
    let(:news_item) { nil }

    it { is_expected.not_to have_css '.hott-header-banner' }
  end
end
