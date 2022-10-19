require 'spec_helper'

RSpec.describe PreferenceCode do
  it { is_expected.to respond_to :code }
  it { is_expected.to respond_to :description }
end
