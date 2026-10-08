require 'spec_helper'

RSpec.describe ParcelGiftChoiceForm do
  subject(:form) { described_class.new(journey:, service_name:, choice:) }

  let(:journey) { Rails.configuration.parcel_gift_journey }
  let(:service_name) { 'uk' }
  let(:choice) { 'parcel_charges' }

  it 'selects the configured destination', :aggregate_failures do
    expect(form).to be_valid
    expect(form.selected_step.id).to eq('parcel_charges')
  end

  [nil, '', 'unknown', %w[parcel_charges], { 'id' => 'parcel_charges' }].each do |invalid_choice|
    context "with invalid choice #{invalid_choice.inspect}" do
      let(:choice) { invalid_choice }

      it 'uses the configured error', :aggregate_failures do
        expect(form).not_to be_valid
        expect(form.errors[:choice]).to eq([journey.chooser.error])
      end
    end
  end

  context 'with an excluded service' do
    let(:service_name) { 'unsupported' }

    it 'rejects a hidden choice', :aggregate_failures do
      expect(form.available_steps).to be_empty
      expect(form).not_to be_valid
    end
  end
end
