module Myott
  class MycommoditiesController < MyottController
    before_action :authenticate, only: %i[new create index]

    def new; end

    def active
      @commodities = get_subscription_targets('active')
    end

    def expired
      @commodities = get_subscription_targets('expired')
    end

    def invalid
      @commodities = get_subscription_targets('invalid')
    end

    def index
      redirect_to new_myott_mycommodity_path and return unless current_subscription('my_commodities')

      @meta = metadata_from_subscription
      @grouped_measure_changes = TariffChanges::GroupedMeasureChange.all(user_id_token, { as_of: as_of.strftime('%Y-%m-%d') })
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
      if current_subscription('my_commodities').nil? && User.update(user_id_token, my_commodities_subscription: 'true')
        # force a reload of memoized user and subscription
        @current_user = nil
        @current_subscription = nil
      end

      Subscription.batch(current_subscription('my_commodities').resource_id,
                         user_id_token,
                         targets: TariffJsonapiParser.new(commodity_codes.uniq).parse)
    end

    def get_subscription_targets(category)
      page = params[:page].presence || 1
      per_page = params[:per_page].presence || 10

      params = { filter: { active_commodities_type: category },
                 page: page,
                 per_page: per_page }
      SubscriptionTarget.all(current_subscription('my_commodities').resource_id, user_id_token, params)
    end

    def metadata_from_subscription
      meta = current_subscription('my_commodities')[:meta]

      OpenStruct.new(
        active: meta['active'].count,
        expired: meta['expired'].count,
        invalid: meta['invalid'].count,
        total: meta.values.flatten.size,
      )
    end

    def as_of
      if params[:as_of].present?
        Date.parse(params[:as_of])
      else
        Time.zone.yesterday
      end
    end
    helper_method :as_of
  end
end
