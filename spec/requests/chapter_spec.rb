require 'spec_helper'

RSpec.describe 'Chapter page', type: :request do
  context 'when requesting as HTML' do
    before do
      VCR.use_cassette('geographical_areas#countries') do
        VCR.use_cassette('chapters#show') do
          visit chapter_path('01')
        end
      end
    end

    it 'displays the link to find commodity' do
      expect(page).to have_link 'Search',
                                href: '/find_commodity'
    end

    it 'displays the section as a link' do
      expect(page).to have_link 'Section I',
                                href: '/sections/1'
    end

    it 'displays the chapter classification' do
      expect(page).to have_content 'Live animals'
    end
  end
end
