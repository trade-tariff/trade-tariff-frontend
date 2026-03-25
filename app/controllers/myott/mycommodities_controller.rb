module Myott
  class MycommoditiesController < MyottController
    before_action :ensure_subscription, except: %i[new create]

    def new
      @upload_form = Myott::CommodityUploadForm.new
    end

    def active
      @targets = get_subscription_targets('active')
    end

    def expired
      @targets = get_subscription_targets('expired')
    end

    def invalid
      @targets = get_subscription_targets('invalid')
    end

    def index; end

    def create
      @upload_form = Myott::CommodityUploadForm.new(upload_params)

      unless @upload_form.valid?
        render :new and return
      end

      result = CommodityCodesExtractionService.new(@upload_form.file).call

      unless result.success?
        @upload_form.errors.add(:file, result.error_message)
        render :new and return
      end

      new_subscriber = subscription.nil?
      unless update_user_commodity_codes(result.codes, new_subscriber)
        @upload_form.errors.add(:file, 'We could not create your subscription. Please try again.')
        return render(:new)
      end
      redirect_to confirmation_myott_mycommodities_path params: { new_subscriber: new_subscriber } and return
    end

    def confirmation
      @new_subscriber = params[:new_subscriber] == 'true'
    end

    def download_changes
      file_data = TariffChanges::TariffChange.download_file(user_id_token, { as_of: as_of.to_fs(:dashed) })

      send_data(
        file_data[:body],
        filename: file_data[:filename],
        type: file_data[:type],
        disposition: 'attachment',
      )
      response.headers['Cache-Control'] = 'no-cache'
    end

    def download_commodities
      file_data = SubscriptionTarget.download_file(subscription.resource_id, user_id_token)

      send_data(
        file_data[:body],
        filename: file_data[:filename],
        type: file_data[:type],
        disposition: 'attachment',
      )
      response.headers['Cache-Control'] = 'no-cache'
    end

    private

    def subscription
      @subscription ||= current_subscription(SubscriptionType::SUBSCRIPTION_TYPE_NAMES[:my_commodities])
    end

    def ensure_subscription
      unless subscription
        redirect_to new_myott_mycommodity_path and return
      end
    end

    def update_user_commodity_codes(commodity_codes, new_subscriber)
      if new_subscriber
        User.update(user_id_token, my_commodities_subscription: 'true')
        reload_subscription
      end
      return false if subscription.nil?

      Subscription.batch(subscription.resource_id,
                         user_id_token,
                         targets: TariffJsonapiParser.new(commodity_codes.uniq).parse)
      true
    rescue StandardError
      false
    end

    def get_subscription_targets(category)
      filters = { filter: { active_commodities_type: category },
                  page: params.fetch(:page, 1),
                  per_page: params.fetch(:per_page, 10) }

      SubscriptionTarget.all(subscription.resource_id, user_id_token, filters)
    end

    def counts_from_subscription_metadata
      counts = subscription&.dig(:meta, :counts) || {}

      OpenStruct.new(
        active: counts.fetch('active', 0),
        expired: counts.fetch('expired', 0),
        invalid: counts.fetch('invalid', 0),
        total: counts.fetch('total', 0),
      )
    end

    def upload_params
      params.fetch(:myott_commodity_upload_form, {}).permit(:file)
    end

    def as_of
      return Time.zone.yesterday if params[:as_of].blank?

      Date.parse(params[:as_of])
    rescue ArgumentError, TypeError
      Time.zone.yesterday
    end

    def commodity_code_counts
      @commodity_code_counts ||= counts_from_subscription_metadata
    end

    def last_change_date
      date = subscription&.dig(:meta, :published, :last_change_date)

      return if date.blank?

      change_date = Date.parse(date)
      change_date if change_date < as_of
    end

    def grouped_measure_changes
      @grouped_measure_changes ||= TariffChanges::GroupedMeasureChange.all(user_id_token, { as_of: as_of.to_fs(:dashed) })
    end

    def commodity_changes
      @commodity_changes ||= TariffChanges::CommodityChange.all(user_id_token, { as_of: as_of.to_fs(:dashed) })
    end

    helper_method :as_of, :commodity_code_counts, :last_change_date, :grouped_measure_changes, :commodity_changes
  end
end
