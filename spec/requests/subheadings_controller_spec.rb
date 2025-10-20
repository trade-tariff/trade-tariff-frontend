require 'spec_helper'

RSpec.describe SubheadingsController, type: :request do
  describe 'page' do
    before do
      VCR.use_cassette('subheadings#show') do
        visit subheading_path('0101210000-10')
      end
    end

    it { expect(page).to have_link 'Search', href: '/find_commodity' }
    it { expect(page).to have_link 'Browse', href: '/browse' }

    it { expect(page).to have_content "There are 3 commodities in this category. Choose the commodity code that best matches your goods to see more information. If your item is not listed by name, it may be shown under what it's used for, what it's made from or 'Other'." }

    it { expect(page).to have_link 'Section I', href: '/sections/1' }
    it { expect(page).to have_link 'Chapter 01', href: '/chapters/01' }
    it { expect(page).to have_link 'Heading 0101', href: '/headings/0101' }

    it { expect(page).to have_content 'Subheading 010121 - Horses' }
    it { expect(page).to have_link 'Pure-bred breeding animals', href: '/commodities/0101210000' }
    it { expect(page).to have_link 'For slaughter', href: '/commodities/0101291000' }
    it { expect(page).to have_link 'Other', href: '/commodities/0101299000' }

    it { expect(page).to have_content 'Chapter notes' }
    it { expect(page).to have_content 'Section notes' }
  end

  context 'when the subheading does not exist and we fetch validity periods', vcr: { cassette_name: 'subheadings#show_0101999999-80' } do
    context 'when the validity periods are present' do
      before do
        stub_api_request('subheadings/0101999999-80/validity_periods')
          .with(query: { as_of: Time.zone.today })
          .to_return jsonapi_response(:validity_periods, validity_periods)

        get subheading_path('0101999999-80')
      end

      let(:validity_periods) { [attributes_for(:validity_period, :subheading)] }

      it { is_expected.to render_template(:show_404) }
    end

    context 'when the validity periods returns not found' do
      before do
        stub_api_request('subheadings/0101999999-80/validity_periods')
          .with(query: { as_of: Time.zone.today })
          .to_return jsonapi_not_found_response

        get subheading_path('0101999999-80')
      end

      it { expect(response).to redirect_to(sections_path) }
    end
  end
end
