require 'spec_helper'

RSpec.describe RulesOfOrigin::OriginReferenceDocument do
  it { is_expected.to respond_to :ord_title }
  it { is_expected.to respond_to :ord_version }
  it { is_expected.to respond_to :ord_date }
  it { is_expected.to respond_to :ord_original }

  describe '#document_path' do
    subject(:document_path) { build(:rules_of_origin_origin_reference_document).document_path }

    it { is_expected.to eq('/roo_origin_reference_documents/211203_ORD_Japan_V1.1.odt') }
  end
end
