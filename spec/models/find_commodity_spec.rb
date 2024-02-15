require 'spec_helper'

RSpec.describe FindCommodity do
  it { is_expected.to respond_to :q }
  it { is_expected.to respond_to :day }
  it { is_expected.to respond_to :month }
  it { is_expected.to respond_to :year }

  describe 'validation' do
    subject { instance.tap(&:valid?).errors.full_messages }

    context 'with valid date' do
      let(:instance) { build :find_commodity }

      it { is_expected.to be_empty }
    end

    context 'with invalid date' do
      let(:instance) { build :find_commodity, day: '0' }

      it { is_expected.to include %r{Enter a valid date} }
    end
  end

  describe '#date' do
    subject { instance.date }

    context 'with valid date' do
      let(:instance) { described_class.new(day: '1', month: '1', year: '2022') }

      it { is_expected.to eql Date.parse('2022-01-01') }
    end

    context 'with invalid date' do
      let(:instance) { described_class.new(day: '0', month: '1', year: '2022') }

      it { is_expected.to be_nil }
    end
  end

  describe '#date=' do
    subject { described_class.new(date:) }

    let(:date) { 3.weeks.ago.to_date }

    it { is_expected.to have_attributes day: date.day }
    it { is_expected.to have_attributes month: date.month }
    it { is_expected.to have_attributes year: date.year }
  end
end
