class Subscription
  include ApiEntity

  set_singular_path '/uk/user/subscriptions/:id'

  attr_accessor :active, :uuid
end
