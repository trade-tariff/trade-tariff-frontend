require 'spec_helper'

RSpec.describe SearchReferencePresenter do
  subject(:presented) { described_class.new(search_reference) }

  let(:search_reference) { build :search_reference, :with_subheading }

  describe '#link' do
    shared_examples 'a search reference link' do |trait, expected_link|
      let(:search_reference) { build :search_reference, trait }

      it { expect(presented.link).to eq(expected_link) }
    end

    it_behaves_like 'a search reference link', :with_chapter, '/chapters/20'
    it_behaves_like 'a search reference link', :with_heading, '/headings/2001'
    it_behaves_like 'a search reference link', :with_subheading, '/subheadings/8418690000-10'
    it_behaves_like 'a search reference link', :with_commodity, '/commodities/8418690000'
  end

  describe '#to_s' do
    it { expect(presented.to_s).to eq('Tomatoes') }
  end
end
