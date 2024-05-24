require 'spec_helper'

RSpec.describe GreenLanes::CheckMovingRequirementsForm, type: :model do
  describe 'validations' do
    subject(:form) { described_class.new(params) }

    before { form.valid? }

    context 'when all the attributes are correct' do
      let(:params) do
        {
          commodity_code: '1234567890',
          country_of_origin: 'IT',
          moving_date: { 1 => 1998, 2 => 12, 3 => 25 },
        }
      end

      it { expect(form.errors).to be_empty }
    end

    context 'when the attributes are incorrect' do
      let(:params) do
        {
          commodity_code: '12345AAA',
          country_of_origin: '',
          moving_date: { 1 => 1998, 2 => 12, 3 => nil },
        }
      end

      it { expect(form.errors[:commodity_code]).to eq(['Commodity code must have 10 digits', 'Commodity code must only contain numbers']) }
      it { expect(form.errors[:country_of_origin]).to eq(['Select the country of origin']) }
      it { expect(form.errors[:moving_date]).to eq(['Enter a valid date']) }
    end
  end
end
