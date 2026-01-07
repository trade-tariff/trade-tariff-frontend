module MyottAuthenticationHelpers
  def stub_unauthenticated_user
    allow(controller).to receive(:current_user).and_return(nil)
  end

  def stub_authenticated_user(user = nil)
    user ||= build(:user)
    allow(controller).to receive(:current_user).and_return(user)
    user
  end

  def stub_current_subscription(subscription_type, subscription)
    allow(controller).to receive(:current_subscription).with(subscription_type).and_return(subscription)
    subscription
  end

  def stub_unauthenticated_user_with_bypass
    allow(controller).to receive(:authenticate)
    stub_unauthenticated_user
  end

  def setup_myott_authentication(
    user: nil,
    user_id_token: 'test_token',
    subscription_type: nil,
    subscription: nil,
    as_of: Time.zone.today,
    bypass_auth: false
  )
    # Always stub authentication method to prevent redirect loops
    allow(controller).to receive(:authenticate) if bypass_auth

    if user == :none || user.nil? && !bypass_auth
      stub_unauthenticated_user
      return { user: nil, user_id_token: user_id_token, subscription: subscription }
    else
      user = stub_authenticated_user(user)
    end

    allow(controller).to receive(:user_id_token).and_return(user_id_token) if user_id_token

    if subscription_type
      subscription = stub_current_subscription(subscription_type, subscription)
    end

    allow(controller).to receive(:as_of).and_return(as_of) if as_of

    {
      user: user,
      user_id_token: user_id_token,
      subscription: subscription,
      as_of: as_of,
    }
  end

  def setup_mycommodities_context(
    user: nil,
    subscription_type: 'my_commodities',
    user_id_token: 'test_token',
    as_of: Time.zone.today
  )
    user ||= build(:user, my_commodities_subscription: true)

    subscription = build(:subscription,
                         active: true,
                         subscription_type: subscription_type,
                         metadata: { commodity_codes: %w[1111111111 22222222222 3333333333 4444444444 5555555555] },
                         meta: { active: %w[1111111111 22222222222], expired: %w[33333333333 44444444444], invalid: %w[55555555555] })

    setup_myott_authentication(
      user: user,
      user_id_token: user_id_token,
      subscription_type: subscription_type,
      subscription: subscription,
      as_of: as_of,
      bypass_auth: true,
    )

    subscription
  end
end
