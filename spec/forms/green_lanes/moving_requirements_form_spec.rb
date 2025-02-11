require 'spec_helper'

RSpec.describe GreenLanes::MovingRequirementsForm, type: :model do
  describe 'validations' do
    subject(:form) { described_class.new(params) }

    let(:year) { GreenLanes::YEAR }
    let(:month) { GreenLanes::MONTH }
    let(:day) { GreenLanes::DAY }

    before { form.valid? }

    context 'when all the attributes are correct', vcr: { cassette_name: 'green_lanes/get_goods_nomenclatures_200' } do
      let(:params) do
        {
          commodity_code: '0201100021',
          country_of_origin: 'IT',
          moving_date: { year => '2022', month => '2', day => '3' },
        }
      end

      it { expect(form.errors).to be_empty }
    end

    context 'when the commodity code does not exist', vcr: { cassette_name: 'green_lanes/get_goods_nomenclatures_404' } do
      let(:params) do
        {
          commodity_code: '1234567890',
          country_of_origin: 'IT',
          moving_date: { year => '2022', month => '2', day => '3' },
        }
      end

      it do
        expect(
          form.errors[:commodity_code],
        ).to eq(['This commodity code is not recognised.<br>Enter a different commodity code.'])
      end
    end

    context 'when the commodity code contains non-digit characters' do
      let(:params) do
        { commodity_code: '12345AAA' }
      end

      it do
        expect(form.errors[:commodity_code]).to eq(["Enter a 10 digit commodity code, for example, '0123456789'",
                                                    "Enter a 10 digit commodity code, for example, '0123456789'"])
      end
    end

    context 'when country has not been selected' do
      let(:params) do
        { country_of_origin: '' }
      end

      it { expect(form.errors[:country_of_origin]).to eq(['Select the non-preferential origin of your goods']) }
    end

    describe 'date validation' do
      context 'when day is empty' do
        let(:params) do
          { moving_date: { year => '1998', month => '12', day => '' } }
        end

        it { expect(form.errors[:moving_date]).to eq(['Enter a valid date, for example, 01 02 2024']) }
      end

      context 'when year is 2 digit instead of 4' do
        let(:params) do
          { moving_date: { year => '24', month => '12', day => '20' } }
        end

        it { expect(form.errors[:moving_date]).to eq(['Enter a valid date, for example, 01 02 2024']) }
      end

      context 'when date is correct' do
        let(:params) do
          { moving_date: { year => '2024', month => '12', day => '20' } }
        end

        it { expect(form.errors[:moving_date]).to be_empty }
      end
    end
  end
end
