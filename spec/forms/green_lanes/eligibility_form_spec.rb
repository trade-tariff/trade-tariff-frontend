require 'spec_helper'

RSpec.describe GreenLanes::EligibilityForm, type: :model do
  describe 'validations' do
    subject(:form) { described_class.new(params) }

    before { form.valid? }

    context 'when all the attributes are present' do
      let(:params) do
        {
          commodity_code: '6203000000',
          moving_goods_gb_to_ni: 'yes',
          free_circulation_in_uk: 'yes',
          end_consumers_in_uk: 'yes',
          ukims: 'yes',
        }
      end

      it { expect(form.errors).to be_empty }
    end

    context 'when the commodity_code is missing' do
      let(:params) do
        {
          commodity_code: '',
          moving_goods_gb_to_ni: 'yes',
          free_circulation_in_uk: 'yes',
          end_consumers_in_uk: 'yes',
          ukims: 'yes',
        }
      end

      it { expect(form.errors).to be_empty }
    end

    context 'when multiple attributes are missing' do
      let(:params) do
        {
          commodity_code: '',
          moving_goods_gb_to_ni: '',
          free_circulation_in_uk: 'yes',
          end_consumers_in_uk: '',
          ukims: 'yes',
        }
      end

      it do
        expect(form.errors[:moving_goods_gb_to_ni])
          .to include('Select an option to tell us if you are moving goods from Great Britain to Northern Ireland')
      end

      it do
        expect(form.errors[:end_consumers_in_uk])
          .to include('Select an option to tell us if your goods are for sale or final use in the UK')
      end
    end

    context 'when all attributes are empty strings' do
      let(:params) do
        {
          commodity_code: '',
          moving_goods_gb_to_ni: '',
          free_circulation_in_uk: '',
          end_consumers_in_uk: '',
          ukims: '',
        }
      end

      it { expect(form.errors[:moving_goods_gb_to_ni]).to include('Select an option to tell us if you are moving goods from Great Britain to Northern Ireland') }
      it { expect(form.errors[:free_circulation_in_uk]).to include('Select an option to tell us if your goods are in free circulation in the UK') }
      it { expect(form.errors[:end_consumers_in_uk]).to include('Select an option to tell us if your goods are for sale or final use in the UK') }
      it { expect(form.errors[:ukims]).to include('Select an option to tell us if you are a UKIMS authorised trader') }
    end
  end
end
