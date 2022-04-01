require 'spec_helper'

RSpec.describe 'commodities/show_404.html.erb', type: :view do
  include TimeMachineUrlHelper

  subject(:rendered_page) { render_page && rendered }

  before do
    assign :commodity_code, '0123456789'
    assign :heading_code, '0123'
    assign :chapter_code, '01'
    assign :validity_periods, periods
    assign :search, search
  end

  let(:render_page) { render template: 'commodities/show_404' }
  let(:periods) { (1..2).map { |i| build :validity_period, months_ago: i } }
  let(:search) { Search.new }

  describe 'page content' do
    it { is_expected.to have_css 'h1', text: 'Commodity 0123456789' }
    it { is_expected.to have_css 'p', text: /for the dates shown below/ }
    it { is_expected.to have_css 'ul.govuk-list.govuk-list--bullet li', count: 2 }

    it { is_expected.to have_css 'li', text: /From \d+ [a-z]{4}[a-z]+ \d{4}/i, count: 2 }
    it { is_expected.to have_css 'li', text: /to \d+ [a-z]{4}[a-z]+ \d{4}/i, count: 1 }

    it { is_expected.to have_css 'li > a', count: 3 }

    it 'links to the current commodities start date' do
      expect(rendered_page).to \
        have_link periods[0].validity_start_date.to_formatted_s(:long),
                  href: commodity_on_date_path('0123456789', periods[0].validity_start_date)
    end

    it 'links to the historical commodities start date' do
      expect(rendered_page).to \
        have_link periods[1].validity_start_date.to_formatted_s(:long),
                  href: commodity_on_date_path('0123456789', periods[1].validity_start_date)
    end

    it 'links to the historical commodities end date' do
      expect(rendered_page).to \
        have_link periods[1].validity_end_date.to_formatted_s(:long),
                  href: commodity_on_date_path('0123456789', periods[1].validity_end_date)
    end

    it { is_expected.to have_link 'heading 0123', href: heading_path('0123') }
    it { is_expected.to have_link 'chapter 01', href: chapter_path('01') }

    it { is_expected.not_to have_css 'p', text: 'Try searching again' }
    it { is_expected.not_to have_css 'p', text: /for \d+ [a-z]+ \d{4}/i }
  end

  context 'with date set to yesterday' do
    let(:search) do
      Search.new 'day' => Time.zone.yesterday.day,
                 'month' => Time.zone.yesterday.month,
                 'year' => Time.zone.yesterday.year
    end

    it { is_expected.to have_css 'p', text: /for \d+ [a-z]+ \d{4}\./i }
  end

  context 'without periods commodity code is valid for' do
    let(:periods) { [] }

    it { is_expected.not_to have_css 'ul.govuk-list' }
    it { is_expected.not_to have_css 'p', text: /for the dates shown/ }
    it { is_expected.to have_css 'p', text: 'Try searching again' }
  end
end
