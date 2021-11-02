require 'spec_helper'

RSpec.describe 'SectionsController', type: :request do
  describe 'GET #index' do
    context 'when requesting as HTML' do
      before do
        allow(TradeTariffFrontend).to receive(:updated_navigation?).and_return false

        VCR.use_cassette('geographical_areas#countries') do
          VCR.use_cassette('sections#index') do
            visit sections_path
          end
        end
      end

      it 'displays the first section as a link' do
        expect(page).to have_link 'Live animals; animal products'
      end

      it 'displays the second section as a link' do
        expect(page).to have_link 'Vehicles, aircraft'
      end

      it 'displays the third section as a link' do
        expect(page).to have_link 'Privacy'
      end
    end

    context 'when HTML with updated_navigation? enabled' do
      let :visit_page do
        VCR.use_cassette('geographical_areas#countries') do
          VCR.use_cassette('sections#index') do
            get sections_path
          end
        end
      end

      context 'with UK service' do
        include_context 'with UK service'

        before { visit_page }

        it { expect(response).to redirect_to '/find_commodity' }
      end

      context 'with XI service' do
        include_context 'with XI service'

        before { visit_page }

        it { expect(response).to redirect_to '/xi/find_commodity' }
      end
    end

    context 'when requesting as JSON' do
      context 'when requested with json format' do
        before do
          VCR.use_cassette('sections#index_api_json_format') do
            get '/sections.json'
          end
        end

        let(:json) { JSON.parse(response.body) }

        it 'renders direct API response' do
          expect(json).to be_kind_of Array
        end

        it 'renders the correct title for the first element' do
          expect(json.first['title']).to eq 'Live animals; animal products'
        end
      end

      context 'when requested with json HTTP Accept header' do
        before do
          VCR.use_cassette('sections#index_api_json_content_type') do
            get '/sections', headers: { 'HTTP_ACCEPT' => 'application/json' }
          end
        end

        let(:json) { JSON.parse(response.body) }

        it 'renders direct API response' do
          expect(json).to be_kind_of Array
        end

        it 'renders the correct title for the first element' do
          expect(json.first['title']).to eq 'Live animals; animal products'
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when requested as HTML' do
      before do
        VCR.use_cassette('geographical_areas#countries') do
          VCR.use_cassette('sections#show') do
            visit section_path(1)
          end
        end
      end

      it 'displays the link to all sections' do
        expect(page).to have_link 'All sections',
                                  href: '/sections'
      end

      it 'displays section name' do
        expect(page).to have_content 'Live animals; animal products'
      end

      it 'displays the first chapter in the section' do
        expect(page).to have_content 'Live animals'
      end

      it 'displays the second chapter in the section' do
        expect(page).to have_content 'Meat and edible meat offal'
      end
    end

    context 'when requested as JSON' do
      context 'when requested with json format' do
        before do
          VCR.use_cassette('sections#show_1_api_json_format') do
            get '/sections/1.json'
          end
        end

        let(:json) { JSON.parse(response.body) }

        it 'renders the correct title' do
          expect(json['title']).to eq 'Live animals; animal products'
        end

        it 'renders direct API response' do
          expect(json['chapters']).to be_kind_of Array
        end
      end

      context 'when requested with json HTTP Accept header' do
        before do
          VCR.use_cassette('sections#show_1_api_json_content_type') do
            get '/sections/1', headers: { 'HTTP_ACCEPT' => 'application/json' }
          end
        end

        let(:json) { JSON.parse(response.body) }

        it 'renders the correct title' do
          expect(json['title']).to eq 'Live animals; animal products'
        end

        it 'renders direct API response' do
          expect(json['chapters']).to be_kind_of Array
        end
      end
    end
  end
end
