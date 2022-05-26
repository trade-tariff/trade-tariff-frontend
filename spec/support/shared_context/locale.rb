RSpec.shared_context 'with Cymru locale' do
  before { allow(I18n).to receive(:locale).and_return :cy }
end
