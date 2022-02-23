require 'spec_helper'

RSpec.describe Chapter do
  describe '.relationships' do
    let(:expected_relationships) do
      %i[
        section
        headings
        section
        chapter
        footnotes
        import_measures
        export_measures
        heading
        overview_measures
        ancestors
        section
        chapter
        footnotes
        import_measures
        export_measures
        commodities
        children
        section
        chapter
        heading
        footnotes
        commodities
      ]
    end

    it { expect(described_class.relationships).to eq(expected_relationships) }
  end
end
