require 'spec_helper'

RSpec.describe GreenLanes::MovingRequirementsForm, type: :model do
  describe 'validations' do
    subject(:form) { described_class.new(params) }

    before { form.valid? }

    context 'when all the attributes are correct', vcr: { cassette_name: 'green_lanes/get_goods_nomenclatures_200' } do
      let(:params) do
        {
          commodity_code: '6203000000',
          country_of_origin: 'IT',
          moving_date: { 1 => 2022, 2 => 2, 3 => 3 },
        }
      end

      it { expect(form.errors).to be_empty }
    end

    context 'when the attributes correct but the commodity code does not exist', vcr: { cassette_name: 'green_lanes/get_goods_nomenclatures_404' } do
      let(:params) do
        {
          commodity_code: '1234567890',
          country_of_origin: 'IT',
          moving_date: { 1 => 2022, 2 => 2, 3 => 3 },
        }
      end

      it { expect(form.errors[:base]).to eq(['No result found for the given commodity code, country of origin and moving date.']) }
    end

    context 'when the attributes are incorrect' do
      let(:params) do
        {
          commodity_code: '12345AAA',
          country_of_origin: '',
          moving_date: { 1 => 1998, 2 => 12, 3 => nil },
        }
      end

      it { expect(form.errors[:commodity_code]).to eq(['Enter a 10 digit commodity code', 'Enter a 10 digit commodity code']) }
      it { expect(form.errors[:country_of_origin]).to eq(['Select the non-preferential origin of your goods']) }
      it { expect(form.errors[:moving_date]).to eq(['Enter a valid date']) }
    end
  end
end
