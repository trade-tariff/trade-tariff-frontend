require 'spec_helper'

RSpec.describe TimeMachineUrlHelper, type: :helper do
  describe '#commodity_on_date_path' do
    subject { commodity_on_date_path '1234567890', date }

    context 'with valid date' do
      let(:date) { Date.parse '2022-01-01' }

      it { is_expected.to eql '/commodities/1234567890?day=1&month=1&year=2022' }
    end

    context 'with invalid date' do
      let(:date) { 'random string' }

      it { is_expected.to eql '/commodities/1234567890' }
    end

    context 'with nil date' do
      let(:date) { nil }

      it { is_expected.to eql '/commodities/1234567890' }
    end
  end

  describe '#heading_on_date_path' do
    subject { heading_on_date_path '1234', date }

    context 'with valid date' do
      let(:date) { Date.parse '2022-01-01' }

      it { is_expected.to eql '/headings/1234?day=1&month=1&year=2022' }
    end

    context 'with invalid date' do
      let(:date) { 'random string' }

      it { is_expected.to eql '/headings/1234' }
    end

    context 'with nil date' do
      let(:date) { nil }

      it { is_expected.to eql '/headings/1234' }
    end
  end

  describe '#chapter_on_date_path' do
    subject { chapter_on_date_path '12', date }

    context 'with valid date' do
      let(:date) { Date.parse '2022-01-01' }

      it { is_expected.to eql '/chapters/12?day=1&month=1&year=2022' }
    end

    context 'with invalid date' do
      let(:date) { 'random string' }

      it { is_expected.to eql '/chapters/12' }
    end

    context 'with nil date' do
      let(:date) { nil }

      it { is_expected.to eql '/chapters/12' }
    end
  end
end
