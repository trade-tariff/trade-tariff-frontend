require 'spec_helper'

RSpec.describe SubheadingsController, type: :request do
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
