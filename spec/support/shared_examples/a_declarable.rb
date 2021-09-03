RSpec.shared_examples 'a declarable' do
  it { is_expected.to respond_to(:declarable) }
end
