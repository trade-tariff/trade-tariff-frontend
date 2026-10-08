require 'spec_helper'

RSpec.describe 'news_items/recent_news', type: :view do
  subject(:rendered_news) { render 'news_items/recent_news', news_items: }

  let(:news_items) { build_list :news_item, 3 }

  it { is_expected.to have_css 'h2', text: 'Latest news' }
  it { is_expected.to have_link 'See all latest news', href: news_items_path }

  it { is_expected.to have_css 'article.news-item p.govuk-body-s a', count: 3 }
  it { is_expected.to have_css 'article.news-item p.tariff-body-subtext a', count: 3 }

  context 'with a publication date in the title' do
    let(:news_items) do
      [build(:news_item, title: "Indonesia Graduation (DCTS) \u2013 6 October 2026", start_date: Date.new(2026, 10, 6))]
    end

    it 'shows the date only in the publication metadata', :aggregate_failures do
      expect(rendered_news).to have_link('Indonesia Graduation (DCTS)', href: news_item_path(news_items.first), exact_text: true)
      expect(rendered_news).to have_css('p.tariff-body-subtext', text: '6 Oct 2026')
      expect(rendered_news).not_to have_text('6 October 2026')
    end
  end
end
