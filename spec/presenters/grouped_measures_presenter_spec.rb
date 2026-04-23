require 'spec_helper'

RSpec.describe GroupedMeasuresPresenter do
  subject(:presenter) do
    described_class.new(
      uk_declarable: uk_declarable,
      xi_declarable: xi_declarable,
      rules_of_origin_schemes: %w[scheme],
      search: search,
      service_chooser: service_chooser,
    )
  end

  let(:search) { instance_double(Search) }

  let(:uk_import_measures) do
    instance_double(
      MeasureCollection,
      import_controls: [measure_b, measure_a],
      customs_duties: [measure_b, measure_a],
      quotas: [measure_b, measure_a],
      trade_remedies: [measure_b, measure_a],
      suspensions: [measure_b, measure_a],
      credibility_checks: [measure_b, measure_a],
      vat_excise: [measure_b, measure_a],
    )
  end

  let(:xi_import_measures) do
    instance_double(
      MeasureCollection,
      customs_duties: [measure_b, measure_a],
      trade_remedies: [measure_b, measure_a],
      suspensions: [measure_b, measure_a],
      credibility_checks: [measure_b, measure_a],
      import_controls: [measure_b, measure_a],
    )
  end

  let(:uk_declarable) do
    instance_double(Commodity, import_measures: uk_import_measures, calculate_duties?: true)
  end

  let(:xi_declarable) do
    instance_double(Commodity, import_measures: xi_import_measures, calculate_duties?: true, meursing_code?: true)
  end

  let(:service_chooser) { class_double(TradeTariffFrontend::ServiceChooser, uk?: true) }
  let(:measure_a) { OpenStruct.new(key: 'a') }
  let(:measure_b) { OpenStruct.new(key: 'b') }

  describe '#uk_sections' do
    it 'returns UK sections in display order' do
      expect(presenter.uk_sections.map { |section| section[:css_id] }).to eq(
        %w[uk_import_controls import_duties quotas trade_remedies suspensions credibility_checks vat_excise],
      )
    end
  end

  describe '#xi_sections' do
    subject(:sections) { presenter.xi_sections }

    let(:service_chooser) { class_double(TradeTariffFrontend::ServiceChooser, uk?: false) }

    it 'returns grouped XI sections in the original order' do
      expect(sections.map { |section| section[:css_id] }).to eq(
        %w[import_duties trade_remedies suspensions credibility_checks vat_excise xi_import_controls uk_import_controls],
      )
    end

    it 'sorts collections by key' do
      expect(sections.first[:collection].map(&:key)).to eq(%w[a b])
    end
  end

  describe '#uk_navigation_items' do
    it 'returns UK navigation labels and anchors' do
      expect(presenter.uk_navigation_items).to include(
        { text: 'Import controls', anchor: '#uk_import_controls' },
        { text: 'Import duties', anchor: '#import_duties' },
        { text: 'Quotas', anchor: '#quotas' },
      )
    end
  end

  describe '#xi_navigation_items' do
    let(:service_chooser) { class_double(TradeTariffFrontend::ServiceChooser, uk?: false) }

    it 'returns XI navigation labels and anchors' do
      expect(presenter.xi_navigation_items).to include(
        { text: 'Import duties', anchor: '#import_duties' },
        { text: 'EU import controls', anchor: '#xi_import_controls' },
        { text: 'UK import controls', anchor: '#uk_import_controls' },
      )
    end
  end

  describe '#navigation_items' do
    context 'when uk service is active' do
      let(:service_chooser) { class_double(TradeTariffFrontend::ServiceChooser, uk?: true) }

      it 'returns uk navigation items' do
        expect(presenter.navigation_items).to eq(presenter.uk_navigation_items)
      end
    end

    context 'when xi service is active' do
      let(:service_chooser) { class_double(TradeTariffFrontend::ServiceChooser, uk?: false) }

      it 'returns xi navigation items' do
        expect(presenter.navigation_items).to eq(presenter.xi_navigation_items)
      end
    end
  end

  describe '#show_meursing_form?' do
    let(:service_chooser) { class_double(TradeTariffFrontend::ServiceChooser, uk?: false) }

    it 'returns true when XI customs duties are present and xi declarable is meursing code' do
      expect(presenter.show_meursing_form?).to be true
    end

    context 'when xi declarable is not a meursing code' do
      let(:xi_declarable) do
        instance_double(Commodity, import_measures: xi_import_measures, calculate_duties?: true, meursing_code?: false)
      end

      it 'returns false' do
        expect(presenter.show_meursing_form?).to be false
      end
    end
  end
end
