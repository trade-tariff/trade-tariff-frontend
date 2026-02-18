class SubscriptionType
  include AuthenticatableApiEntity

  SUBSCRIPTION_TYPE_NAMES = {
    stop_press: 'stop_press',
    my_commodities: 'my_commodities',
  }.freeze

  attr_accessor :id, :name

  def my_commodities_subscription?
    name == SUBSCRIPTION_TYPE_NAMES[:my_commodities]
  end

  def stop_press_subscription?
    name == SUBSCRIPTION_TYPE_NAMES[:stop_press]
  end
end
