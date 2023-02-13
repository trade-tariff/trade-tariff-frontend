require 'spec_helper'

RSpec.describe GovukFrontendHelper, type: :helper do
  describe '#contents_list_item' do
    subject { contents_list_item 'Some link', '#some-link' }

    it { is_expected.to have_css 'li.gem-c-contents-list__list-item' }
    it { is_expected.to have_css 'li.gem-c-contents-list__list-item--dashed' }
    it { is_expected.to have_css 'li a.gem-c-contents-list__link' }
    it { is_expected.to have_link 'Some link', href: '#some-link' }

    context 'with custom link classes' do
      subject { contents_list_item 'Some link', '#some-link', 'some-custom-class' }

      it { is_expected.to have_css 'li a.gem-c-contents-list__link.some-custom-class' }
    end

    context 'with custom url generation' do
      subject do
        contents_list_item('Some link', { id: 10 }) { |item| "/page/#{item[:id]}" }
      end

      it { is_expected.to have_link 'Some link', href: '/page/10' }
    end
  end

  describe '#back_to_top_link' do
    subject { back_to_top_link }

    it { is_expected.to have_link 'Back to top', href: '#content' }
    it { is_expected.to have_css 'a.govuk-\!-display-none-print' }
  end

  describe '#contents_list' do
    subject { contents_list list }

    let :list do
      [
        ['First section', '#section1'],
        ['Second section', '#section2'],
        ['Third section', '#section3'],
      ]
    end

    it { is_expected.to have_css 'nav.gem-c-contents-list' }
    it { is_expected.to have_css 'nav h2.gem-c-contents-list__title', text: 'Contents' }
    it { is_expected.to have_css 'nav ol.gem-c-contents-list__list li a', count: 3 }
    it { is_expected.to have_link 'Second section', href: '#section2' }

    context 'without title' do
      subject { contents_list list, title: false }

      it { is_expected.not_to have_css 'h2' }
    end

    context 'with custom title' do
      subject { contents_list list, title: 'List title' }

      it { is_expected.to have_css 'h2', text: 'List title' }
    end

    context 'with extra nav classes' do
      subject { contents_list list, classes: 'another' }

      it { is_expected.to have_css 'nav.gem-c-contents-list.another' }
    end

    context 'with extra nav params' do
      subject { contents_list list, role: 'testing' }

      it { is_expected.to have_css 'nav[role="testing"]' }
    end

    context 'with extra list item classes' do
      subject { contents_list list, item_classes: 'listitem' }

      it { is_expected.to have_css 'nav ol li a.listitem' }
    end

    context 'with custom link generation' do
      subject { contents_list(list) { |item| item.gsub '#', '/page/' } }

      it { is_expected.to have_link 'First section', href: '/page/section1' }
    end
  end
end
