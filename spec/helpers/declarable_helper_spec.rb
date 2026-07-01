require 'spec_helper'

RSpec.describe DeclarableHelper, type: :helper, vcr: { cassette_name: 'geographical_areas#it' } do
  describe '#supplementary_unit_for' do
    subject(:supplementary_unit_for) { helper.supplementary_unit_for(uk_declarable, xi_declarable, country) }

    let(:uk_declarable) { instance_double(Commodity) }
    let(:xi_declarable) { instance_double(Commodity) }
    let(:country) { 'IT' }

    before do
      service_double = instance_double(DeclarableUnitService, call: '<p>supplementary unit</p>')

      allow(DeclarableUnitService).to receive(:new).with(uk_declarable, xi_declarable, country).and_return(service_double)
    end

    it { is_expected.to eq('<p>supplementary unit</p>') }
    it { is_expected.to be_html_safe }
  end
end
