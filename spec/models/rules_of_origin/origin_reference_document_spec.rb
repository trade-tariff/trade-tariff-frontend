require 'spec_helper'

RSpec.describe RulesOfOrigin::OriginReferenceDocument do
  it { is_expected.to respond_to :ord_title }
  it { is_expected.to respond_to :ord_version }
  it { is_expected.to respond_to :ord_date }
  it { is_expected.to respond_to :ord_original }
end
