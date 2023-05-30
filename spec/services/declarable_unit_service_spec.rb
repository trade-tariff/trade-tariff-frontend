require 'spec_helper'

RSpec.describe DeclarableUnitService do
  describe '#call' do
    subject(:result) { described_class.new(uk_declarable, xi_declarable, country).call }

    let(:uk_declarable) { build(:commodity, import_measures: uk_import_measures) }
    let(:xi_declarable) { build(:commodity, import_measures: xi_import_measures) }

    let(:uk_import_measures) { [] }
    let(:xi_import_measures) { [] }
    let(:country) { nil }

    context 'when the service is uk' do
      include_context 'with UK service'

      context 'when there are supplementary units' do
        let(:uk_import_measures) { [attributes_for(:measure, :import_export_supplementary)] }

        it { is_expected.to eq('Number of items (p/st)') }
      end

      context 'when the country is provided and there are unit measures' do
        let(:country) { 'FR' }
        let(:uk_import_measures) { [attributes_for(:measure, :third_country, :with_measurement_unit_measure_components)] }

        it { is_expected.to include('hectokilogram of drained net weight') }
      end

      context 'when the country is provided and there are excise measures' do
        let(:country) { 'FR' }
        let(:uk_import_measures) { [attributes_for(:measure, :excise, :with_measurement_unit_measure_components)] }

        it { is_expected.to include('hectokilogram of drained net weight') }
      end

      context 'when there are no excise or unit measures' do
        let(:country) { 'FR' }
        let(:uk_import_measures) { [] }

        it { is_expected.to eq('There are no supplementary unit measures assigned to this commodity') }
      end

      context 'when the country is not provided and there are unit measures' do
        let(:country) { nil }
        let(:uk_import_measures) do
          [
            attributes_for(
              :measure,
              :third_country,
              :with_measurement_unit_measure_components,
            ),
            attributes_for(
              :measure,
              :third_country,
              :erga_omnes,
              :with_measurement_unit_measure_components,
            ),
          ]
        end

        it { is_expected.to include('hectokilogram of drained net weight') }
      end

      context 'when the country is not provided and there are excise measures' do
        let(:country) { nil }
        let(:uk_import_measures) { [attributes_for(:measure, :excise, :with_measurement_unit_measure_components)] }

        it { is_expected.to include('hectokilogram of drained net weight') }
      end

      context 'when the country is not provided and there are no excise or unit measures' do
        let(:country) { nil }
        let(:uk_import_measures) { [] }

        it { is_expected.to eq('There are no supplementary unit measures assigned to this commodity') }
      end
    end

    context 'when the service is xi' do
      include_context 'with XI service'

      context 'when there are supplementary units' do
        let(:xi_import_measures) { [attributes_for(:measure, :import_export_supplementary)] }

        it { is_expected.to eq('Number of items (p/st)') }
      end

      context 'when the country is provided and there are unit measures' do
        let(:country) { 'FR' }
        let(:xi_import_measures) { [attributes_for(:measure, :third_country, :with_measurement_unit_measure_components)] }

        it { is_expected.to include('hectokilogram of drained net weight') }
      end

      context 'when the country is provided and there are excise measures' do
        let(:country) { 'FR' }
        let(:uk_import_measures) { [attributes_for(:measure, :excise, :with_measurement_unit_measure_components)] }

        it { is_expected.to include('hectokilogram of drained net weight') }
      end

      context 'when there are no excise or unit measures' do
        let(:country) { 'FR' }
        let(:xi_import_measures) { [] }

        it { is_expected.to eq('There are no supplementary unit measures assigned to this commodity') }
      end

      context 'when the country is not provided and there are unit measures' do
        let(:country) { nil }
        let(:xi_import_measures) do
          [
            attributes_for(
              :measure,
              :third_country,
              :with_measurement_unit_measure_components,
            ),
            attributes_for(
              :measure,
              :third_country,
              :erga_omnes,
              :with_measurement_unit_measure_components,
            ),
          ]
        end

        it { is_expected.to include('hectokilogram of drained net weight') }
      end

      context 'when the country is not provided and there are excise measures' do
        let(:country) { nil }
        let(:uk_import_measures) { [attributes_for(:measure, :excise, :with_measurement_unit_measure_components)] }

        it { is_expected.to include('hectokilogram of drained net weight') }
      end

      context 'when the country is not provided and there are no excise or unit measures' do
        let(:country) { nil }
        let(:xi_import_measures) { [] }

        it { is_expected.to eq('There are no supplementary unit measures assigned to this commodity') }
      end

      context 'when the uk declarable is nil and there are no excise or unit measures' do
        let(:uk_declarable) { nil }
        let(:xi_import_measures) { [] }

        it { is_expected.to eq('There are no supplementary unit measures assigned to this commodity') }
      end
    end
  end
end
