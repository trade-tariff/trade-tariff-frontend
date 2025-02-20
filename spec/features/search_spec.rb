require 'spec_helper'

RSpec.describe 'Search', :js do
  context 'with find_commodity page' do
    include_context 'with latest news stubbed'
    include_context 'with news updates stubbed'

    context 'when reaching the search page' do
      it 'renders the search container properly' do
        VCR.use_cassette('search#check') do
          visit find_commodity_path

          expect(page).to have_content('UK Integrated Online Tariff')
          expect(page).to have_content('Look up commodity codes, duty and VAT rates')
          expect(page).to have_content('Search')
          expect(page).to have_content('Browse')

          expect(page.find('#autocomplete input')).to be_present
        end
      end
    end
  end

  context 'when doing a full quota search' do
    context 'when reaching the quota search form' do
      it 'contains quota search params inputs' do
        VCR.use_cassette('search#quota_search_form') do
          visit quota_search_path

          expect(page).to have_content('Quotas')

          expect(page.find('#goods_nomenclature_item_id')).to be_present
          expect(page.find('#geographical_area_id')).to be_present
          expect(page.find('#order_number')).to be_present
          expect(page.find('#critical')).to be_present
          expect(page.find('#status')).to be_present
          expect(page.find('#day')).to be_present
          expect(page.find('#month')).to be_present
          expect(page.find('#year')).to be_present
          expect(page.find('input[name="new_search"]')).to be_present

          expect(page).not_to have_content('Quota search results')
        end
      end
    end

    context 'when getting back some quota search results' do
      it 'performs search and render results' do
        VCR.use_cassette('search#quota_search_results') do
          visit quota_search_path

          expect(page).to have_content('Quotas')

          page.find('#order_number').set('050088')
          page.find('#day').set('16')
          page.find('#month').set('03')
          page.find('#year').set('2022')
          page.find('input[name="new_search"]').click

          expect(page).to have_content('Quota search results')
          expect(page).to have_content('050088')
          expect(page).to have_link('2106909800', href: '/subheadings/2106909800-80?day=16&month=03&year=2022')
          expect(page).to have_content('All countries (1011)')
        end
      end
    end
  end

  describe 'when reaching the tools page' do
    it 'has the Tools link present on the page' do
      visit tools_path

      expect(page).to have_content('Tools')
    end
  end

  context 'when using the chemical search' do
    let(:name) { 'CAS' }

    context 'when reaching the chemical search form' do
      it 'contains chemical search params inputs' do
        VCR.use_cassette('search#chemical_search_form') do
          visit chemical_search_path

          expect(page.find('#cas')).to be_present
          expect(page.find('#name')).to be_present
          expect(page.find('input[name="new_search"]')).to be_present

          expect(page).not_to have_content('Chemical search results')
        end
      end
    end

    context 'when getting back some chemical search results' do
      it 'performs search by CAS number and render results' do
        VCR.use_cassette('search#chemical_cas_search_results') do
          visit chemical_search_path

          expect(page).to have_content(name)

          page.find('#cas').set('121-17-5')
          page.find('input[name="new_search"]').click

          expect(page).to have_content('Chemical search results for “121-17-5”')
          expect(page).to have_content('4-chloro-alpha,alpha,alpha-trifluoro-3-nitrotoluene')
          expect(page).to have_link('Other', href: '/commodities/2904990000')
        end
      end

      it 'performs search by chemical name and render results' do
        VCR.use_cassette('search#chemical_name_search_results') do
          visit chemical_search_path

          expect(page).to have_content(name)

          page.find('#name').set('benzene')
          page.find('input[name="new_search"]').click

          expect(page).to have_content('Chemical search results for “benzene”')
          expect(page).to have_content('22199-08-2')
          expect(page).to have_content('4-amino-N-(pyrimidin-2(1H)-ylidene-κN 1)benzenesulfonamidato-κOsilver')
          expect(page).to have_link('Other', href: '/commodities/2843290000')
        end
      end
    end
  end
end
