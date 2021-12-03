require 'spec_helper'

RSpec.describe 'Search', js: true do
  context 'with find_commodity page' do
    include_context 'with latest news stubbed'

    context 'when reaching the search page' do
      it 'renders the search container properly' do
        VCR.use_cassette('search#check') do
          visit find_commodity_path

          expect(page).to have_content('UK Integrated Online Tariff')
          expect(page).to have_content('Look up commodity codes, duty and VAT rates')
          expect(page).to have_content('Search')
          expect(page).to have_content('Browse')

          expect(page.find('.autocomplete__input#q')).to be_present
        end
      end
    end

    context 'when hitting the autocomplete fields' do
      it 'fetches data from the server as we type' do
        VCR.use_cassette('search#gold') do
          visit find_commodity_path

          page.find('#new_search .autocomplete__input#q').click

          page.find('#new_search .autocomplete__input#q').set('gold')
          sleep 1

          expect(page.find('#new_search .autocomplete__option--focused').text).to eq('gold')

          using_wait_time 1 do
            expect(page.find_all('#new_search .autocomplete__option').length).to be > 1
          end

          expect(page.find('#new_search .autocomplete__option--focused').text).to eq('gold')
          expect(page).to have_content('gold - gold coin')

          page.find('#new_search .autocomplete__option--focused').click

          # trying to see if redirect done by JS needs some sleep to be caught up
          sleep 1

          expect(page).to have_content('Search results for ‘gold’')
        end
      end
    end

    context 'when no result can be found' do
      it 'handles no results found' do
        VCR.use_cassette('search#gibberish') do
          visit find_commodity_path

          page.find('#new_search .autocomplete__input#q').click

          page.find('#new_search .autocomplete__input#q').set('dsauidoasuiodsa')

          sleep 1

          expect(page.find_all('#new_search .autocomplete__option').length).to eq(1)
          expect(page.find('#new_search .autocomplete__option--focused').text).to eq('dsauidoasuiodsa')
          sleep 1

          page.find('#new_search .autocomplete__option--focused').click

          # trying to see if redirect done by JS needs some sleep to be caught up
          sleep 1

          expect(page).to have_content('Search results for ‘dsauidoasuiodsa’')
          expect(page).to have_content('There are no results matching your query.')
        end
      end
    end

    context 'when SEARCH_BANNER enabled' do
      before { allow(TradeTariffFrontend).to receive(:search_banner?).and_return true }

      it 'fetches data from the server as we type' do
        VCR.use_cassette('search#gold') do
          visit find_commodity_path

          page.find('#new_search .autocomplete__input#q').click

          page.find('#new_search .autocomplete__input#q').set('gold')
          sleep 1

          expect(page.find('#new_search .autocomplete__option--focused').text).to eq('gold')

          using_wait_time 1 do
            expect(page.find_all('#new_search .autocomplete__option').length).to be > 1
          end

          expect(page.find('#new_search .autocomplete__option--focused').text).to eq('gold')
          expect(page).to have_content('gold - gold coin')

          page.find('#new_search .autocomplete__option--focused').click

          # trying to see if redirect done by JS needs some sleep to be caught up
          sleep 1

          expect(page).to have_content('Search results for ‘gold’')
        end
      end
    end
  end

  context 'when doing a full quota search' do
    before do
      Rails.cache.clear
    end

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

          page.find('#goods_nomenclature_item_id').set('0301')
          page.find('#order_number').set('0906')
          page.find('#day').set('01')
          page.find('#month').set('01')
          page.find('#year').set('2019')
          page.find('input[name="new_search"]').click

          using_wait_time 1 do
            expect(page).to have_content('Quota search results')
            expect(page).to have_content('090671')
            expect(page).to have_content('0301919011')
            expect(page).to have_content('Faroe Islands (FO)')
          end
        end
      end
    end
  end

  context 'when doing an additional code search' do
    before do
      Rails.cache.clear
    end

    context 'when reaching the additional code search form' do
      it 'contains additional code search params inputs' do
        VCR.use_cassette('search#additional_code_search_form') do
          visit additional_code_search_path

          expect(page).to have_content('Additional code')

          expect(page.find('#code')).to be_present
          expect(page.find('#type')).to be_present
          expect(page.find('#description')).to be_present
          expect(page.find('input[name="new_search"]')).to be_present

          expect(page).not_to have_content('Additional code search results')
        end
      end
    end

    context 'when getting back some additional code search results' do
      it 'performs search and render results' do
        VCR.use_cassette('search#additional_code_search_form') do
          VCR.use_cassette('search#additional_code_search_results') do
            visit additional_code_search_path

            expect(page).to have_content('Additional code')

            page.find('#code').set('119')
            page.find('input[name="new_search"]').click

            using_wait_time 1 do
              expect(page).to have_content('Additional code search results')
              expect(page).to have_content('B119')
              expect(page).to have_content('Wenzhou Jiangnan Steel Pipe Manufacturing, Co. Ltd., Yongzhong')
              expect(page).to have_content('Of stainless steel')
            end
          end
        end
      end
    end
  end

  context 'when using the certificate search' do
    before do
      Rails.cache.clear
    end

    context 'when reaching the certificate search form' do
      it 'contains certificate search params inputs' do
        VCR.use_cassette('search#certificate_search_form') do
          visit certificate_search_path

          expect(page).to have_content('Certificate')

          expect(page.find('#code')).to be_present
          expect(page.find('#type')).to be_present
          expect(page.find('#description')).to be_present
          expect(page.find('input[name="new_search"]')).to be_present

          expect(page).not_to have_content('Certificate search results')
        end
      end
    end

    context 'when getting back some certificate search results' do
      it 'performs search and render results' do
        VCR.use_cassette('search#certificate_search_form') do
          VCR.use_cassette('search#certificate_search_results') do
            visit certificate_search_path

            expect(page).to have_content('Certificate')

            page.find('#code').set('119')
            page.find('input[name="new_search"]').click

            using_wait_time 1 do
              expect(page).to have_content('Certificate search results')
              expect(page).to have_content('C119')
              expect(page).to have_content('Authorised Release Certificate — EASA Form 1 (Appendix I to Annex I to Regulation (EU) No 748/2012), or equivalent certificate')
              expect(page).to have_content('Carbon dioxide')
            end
          end
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
    before do
      Rails.cache.clear
    end

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

          using_wait_time 1 do
            expect(page).to have_content('Chemical search results for “121-17-5”')
            expect(page).to have_content('4-chloro-alpha,alpha,alpha-trifluoro-3-nitrotoluene')
            expect(page).to have_link('Other', href: '/commodities/2904990000')
          end
        end
      end

      it 'performs search by chemical name and render results' do
        VCR.use_cassette('search#chemical_name_search_results') do
          visit chemical_search_path

          expect(page).to have_content(name)

          page.find('#name').set('benzene')
          page.find('input[name="new_search"]').click

          using_wait_time 1 do
            expect(page).to have_content('Chemical search results for “benzene”')
            expect(page).to have_content('22199-08-2')
            expect(page).to have_content('4-amino-N-(pyrimidin-2(1H)-ylidene-κN 1)benzenesulfonamidato-κOsilver')
            expect(page).to have_link('Other', href: '/commodities/2843290000')
          end
        end
      end
    end
  end
end
