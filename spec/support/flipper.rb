# spec/support/flipper.rb
RSpec.configure do |config|
  config.before do
    Flipper.instance = Flipper.new(Flipper::Adapters::Memory.new)
    Current.reset
  end
end
