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
  end

  describe '#back_to_top_link' do
    subject { back_to_top_link }

    it { is_expected.to have_link 'Back to top', href: '#content' }
    it { is_expected.to have_css 'a.govuk-\!-display-none-print' }
  end
end
