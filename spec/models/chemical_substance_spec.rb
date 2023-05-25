require 'spec_helper'

RSpec.describe ChemicalSubstance do
  it { is_expected.to respond_to :cus }
  it { is_expected.to respond_to :cas_rn }
  it { is_expected.to respond_to :goods_nomenclature_sid }
  it { is_expected.to respond_to :goods_nomenclature_item_id }
  it { is_expected.to respond_to :producline_suffix }
  it { is_expected.to respond_to :name }

  describe '#ci?' do
    subject { build(:chemical_substance, nomen:) }

    context 'when the nomen is CI' do
      let(:nomen) { 'CI' }

      it { is_expected.to be_ci }
    end

    context 'when the nomen is not CI' do
      let(:nomen) { 'INN' }

      it { is_expected.not_to be_ci }
    end
  end

  describe '#common?' do
    subject { build(:chemical_substance, nomen:) }

    context 'when the nomen is COMMON' do
      let(:nomen) { 'COMMON' }

      it { is_expected.to be_common }
    end

    context 'when the nomen is not COMMON' do
      let(:nomen) { 'INN' }

      it { is_expected.not_to be_common }
    end
  end

  describe '#inci?' do
    subject { build(:chemical_substance, nomen:) }

    context 'when the nomen is INCI' do
      let(:nomen) { 'INCI' }

      it { is_expected.to be_inci }
    end

    context 'when the nomen is not INCI' do
      let(:nomen) { 'INN' }

      it { is_expected.not_to be_inci }
    end
  end

  describe '#inn?' do
    subject { build(:chemical_substance, nomen:) }

    context 'when the nomen is INN' do
      let(:nomen) { 'INN' }

      it { is_expected.to be_inn }
    end

    context 'when the nomen is not INN' do
      let(:nomen) { 'INNM' }

      it { is_expected.not_to be_inn }
    end
  end

  describe '#innm?' do
    subject { build(:chemical_substance, nomen:) }

    context 'when the nomen is INNM' do
      let(:nomen) { 'INNM' }

      it { is_expected.to be_innm }
    end

    context 'when the nomen is not INNM' do
      let(:nomen) { 'INN' }

      it { is_expected.not_to be_innm }
    end
  end

  describe '#iso?' do
    subject { build(:chemical_substance, nomen:) }

    context 'when the nomen is ISO' do
      let(:nomen) { 'ISO' }

      it { is_expected.to be_iso }
    end

    context 'when the nomen is not ISO' do
      let(:nomen) { 'INN' }

      it { is_expected.not_to be_iso }
    end
  end

  describe '#isom?' do
    subject { build(:chemical_substance, nomen:) }

    context 'when the nomen is ISOM' do
      let(:nomen) { 'ISOM' }

      it { is_expected.to be_isom }
    end

    context 'when the nomen is not ISOM' do
      let(:nomen) { 'INN' }

      it { is_expected.not_to be_isom }
    end
  end

  describe '#iubmb?' do
    subject { build(:chemical_substance, nomen:) }

    context 'when the nomen is IUBMB' do
      let(:nomen) { 'IUBMB' }

      it { is_expected.to be_iubmb }
    end

    context 'when the nomen is not IUBMB' do
      let(:nomen) { 'INN' }

      it { is_expected.not_to be_iubmb }
    end
  end

  describe '#iupac?' do
    subject { build(:chemical_substance, nomen:) }

    context 'when the nomen is IUPAC' do
      let(:nomen) { 'IUPAC' }

      it { is_expected.to be_iupac }
    end

    context 'when the nomen is not IUPAC' do
      let(:nomen) { 'INN' }

      it { is_expected.not_to be_iupac }
    end
  end

  describe '#iupac_gen1?' do
    subject { build(:chemical_substance, nomen:) }

    context 'when the nomen is IUPAC-GEN1' do
      let(:nomen) { 'IUPAC-GEN1' }

      it { is_expected.to be_iupac_gen1 }
    end

    context 'when the nomen is not IUPAC-GEN1' do
      let(:nomen) { 'INN' }

      it { is_expected.not_to be_iupac_gen1 }
    end
  end
end
