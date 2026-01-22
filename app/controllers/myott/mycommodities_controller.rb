module Myott
  class MycommoditiesController < MyottController
    before_action except: %i[new create] do
      redirect_to new_myott_mycommodity_path unless current_subscription('my_commodities')
    end

    def new; end

    def active
      @targets = get_subscription_targets('active')
    end

    def expired
      @targets = get_subscription_targets('expired')
    end

    def invalid
      @targets = get_subscription_targets('invalid')
    end

    def index
      @meta = counts_from_subscription_metadata
      @grouped_measure_changes = TariffChanges::GroupedMeasureChange.all(user_id_token, { as_of: as_of.to_fs(:dashed) })
      @commodity_changes = TariffChanges::CommodityChange.all(user_id_token, { as_of: as_of.to_fs(:dashed) })
    end

    def create
      new_subscriber = current_subscription('my_commodities').nil?
      result = CommodityCodesExtractionService.new(params[:fileUpload1]).call

      unless result.success?
        @alert = result.error_message
        render :new and return
      end

      update_user_commodity_codes(result.codes)
      redirect_to confirmation_myott_mycommodities_path params: { new_subscriber: new_subscriber } and return
    end

    def confirmation
      @new_subscriber = params[:new_subscriber] == 'true'
    end

    def download
      file_data = TariffChanges::TariffChange.download_file(user_id_token, { as_of: as_of.to_fs(:dashed) })

      headers['Content-Disposition'] = file_data[:content_disposition]
      headers['Content-Type'] = file_data[:content_type]
      headers['Content-Transfer-Encoding'] = 'binary'
      headers['Cache-Control'] = 'no-cache'

      self.response_body = file_data[:body]
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

    def counts_from_subscription_metadata
      subscription = current_subscription('my_commodities')
      counts = subscription&.dig(:meta, :counts) || {}

      OpenStruct.new(
        active: counts['active'] || 0,
        expired: counts['expired'] || 0,
        invalid: counts['invalid'] || 0,
        total: counts['total'] || 0,
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
