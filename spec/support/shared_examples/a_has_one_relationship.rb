RSpec.shared_examples 'a has_one relationship' do |relation|
  it { is_expected.to respond_to(relation) }
end
