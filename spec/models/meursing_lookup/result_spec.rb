require 'spec_helper'

RSpec.describe MeursingLookup::Result do
  subject(:meursing_result) { described_class.new(meursing_additional_code_id: 'foo') }

  it { is_expected.to have_attributes(meursing_additional_code_id: 'foo') }
  it { is_expected.not_to be_persisted }
end
