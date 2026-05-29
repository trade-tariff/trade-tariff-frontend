# spec/support/flipper.rb
#
# Flipper::Engine auto-loads flipper/test_help when Rails.env.test?. That
# file registers its own before(:suite) and before(:each) hooks that configure
# a shared Memory adapter and reset all feature flags between examples.
#
# Our only responsibility here is to reset Current.flipper_actor, which is
# set per-request by ApplicationController and must not bleed between tests.
RSpec.configure do |config|
  config.before { Current.reset }
end
