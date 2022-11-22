require 'spec_helper'

RSpec.describe News::Collection do
  it { is_expected.to respond_to :name }
end
