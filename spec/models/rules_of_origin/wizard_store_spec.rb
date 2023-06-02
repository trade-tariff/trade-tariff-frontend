require 'spec_helper'

RSpec.describe RulesOfOrigin::WizardStore do
  subject(:store) { described_class.new backing_store, 'testkey' }

  let(:backing_store) { {} }

  describe '#initialize' do
    it { is_expected.to be_instance_of described_class }
  end

  describe '#persist' do
    subject { backing_store['rules_of_origin-testkey'] }

    before do
      freeze_time
      store.persist 'foo' => 'bar'
    end

    it { is_expected.to include 'foo' => 'bar' }
    it { is_expected.to include 'modified' => Time.zone.now.utc.iso8601 }
  end

  describe 'garbage collection' do
    subject { backing_store.keys }

    before { store.persist 'c' => 'd' }

    context 'with nothing to collect' do
      let :backing_store do
        {
          'rules_of_origin-older' => {
            'a' => 'b',
            'modified' => 1.minute.ago.utc.iso8601,
          },
        }
      end

      it { is_expected.to include 'rules_of_origin-testkey' }
      it { is_expected.to include 'rules_of_origin-older' }
    end

    context 'with old records to collect' do
      let :backing_store do
        {}.tap do |store|
          1.upto(8) do |i|
            store["rules_of_origin-old#{i}"] = {
              'a' => 'b',
              'modified' => i.minutes.ago.utc.iso8601,
            }
          end
        end
      end

      it { is_expected.to have_attributes length: 5 }
      it { is_expected.to include 'rules_of_origin-testkey' }
      it { is_expected.to include 'rules_of_origin-old1' }
      it { is_expected.to include 'rules_of_origin-old4' }
      it { is_expected.not_to include 'rules_of_origin-old5' }
      it { is_expected.not_to include 'rules_of_origin-old8' }
    end
  end
end
