require 'spec_helper'

RSpec.describe SearchResult::SectionSerializer do
  subject(:serializer) { described_class.new(section) }

  let(:section) { build(:section) }

  describe '#as_json' do
    subject { serializer.as_json }

    it { is_expected.to include 'type' => 'section' }
    it { is_expected.to include 'numeral' => section.numeral }
    it { is_expected.to include 'position' => section.position }
    it { is_expected.to include 'title' => section.title }
    it { is_expected.to include 'chapter_from' }
    it { is_expected.to include 'chapter_to' }
    it { is_expected.to include 'section_note' }
  end
end
