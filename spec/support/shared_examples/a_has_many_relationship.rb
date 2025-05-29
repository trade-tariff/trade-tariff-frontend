RSpec.shared_examples 'a has_many relationship' do |relation|
  it { is_expected.to respond_to(relation) }
  it { is_expected.to have_attributes(relation => []) }
end
