module Myott
  class MycommoditiesController < MyottController
    before_action :authenticate, only: %i[new create index]

    def new; end

    def active
      get_subscription_targets 'active'
    end

    def expired
      get_subscription_targets 'expired'
    end

    def invalid
      get_subscription_targets 'invalid'
    end

    def index
      subscription = get_subscription('my_commodities')
      redirect_to new_myott_mycommodity_path and return unless subscription

      meta = subscription[:meta]

      @active_commodity_codes  ||= meta['active']
      @expired_commodity_codes ||= meta['expired']
      @invalid_commodity_codes ||= meta['invalid']

      @total_commodity_codes = meta.values.flatten.size
    end

    def create
      result = CommodityCodesExtractionService.new(params[:fileUpload1]).call

      unless result.success?
        @alert = result.error_message
        render :new and return
      end

      update_user_commodity_codes(result.codes)
      redirect_to myott_mycommodities_path
    end

    private

    def update_user_commodity_codes(commodity_codes)
      subscription = get_subscription('my_commodities')

      subscription_id = if subscription.nil? && User.update(user_id_token, my_commodities_subscription: 'true')
                          @current_user = nil # force a reload of memoized user or subscription will not be found
                          get_subscription('my_commodities').resource_id
                        else
                          subscription.resource_id
                        end

      Subscription.batch(subscription_id,
                         user_id_token,
                         targets: TariffJsonapiParser.new(commodity_codes.uniq).parse,
                         subscription_type: 'my_commodities')
    end

    def get_subscription_targets(category)
      subscription_id = get_subscription('my_commodities').resource_id

      page = params[:page].presence || 1
      per_page = params[:per_page].presence || 10

      params = { filter: { active_commodities_type: category },
                 page: page,
                 per_page: per_page }

      my_commodities = SubscriptionTarget.all(subscription_id, user_id_token, params)
      @commodities = my_commodities
      @total_commodities_count = my_commodities.total_count
      @category = category.capitalize

      render :list
    end
  end
end
