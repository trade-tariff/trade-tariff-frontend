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

    def index
      @commodity_code_counts = counts_from_subscription_metadata
      @grouped_measure_changes = TariffChanges::GroupedMeasureChange.all(user_id_token, { as_of: as_of.to_fs(:dashed) })
      @commodity_changes = TariffChanges::CommodityChange.all(user_id_token, { as_of: as_of.to_fs(:dashed) })
    end

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
      if TradeTariffFrontend.myott_data_export_enabled?
        redirect_to create_data_export_myott_mycommodities_path(export_type: 'ccwl') and return
      else
        file_data = SubscriptionTarget.download_file(subscription.resource_id, user_id_token)
        send_file_to_browser(file_data)
      end
    end

    def create_data_export
      export_type = params[:export_type] || 'ccwl'
      @data_export = DataExport.create!(subscription.resource_id, user_id_token, { export_type: export_type })
    end

    def get_data_export_status
      data_export = DataExport.find(subscription.resource_id, params[:export_id], user_id_token)
      return render json: { status: 'not_found' }, status: :not_found if data_export.blank?

      render json: { status: data_export.status, export_id: data_export.resource_id }
    end

    def download_data_export
      file_data = DataExport.download_file(subscription.resource_id, params[:export_id], user_id_token)
      return head :not_found if file_data.blank?

      send_file_to_browser(file_data)
    end

    private

    def send_file_to_browser(file_data)
      send_data(
        file_data[:body],
        filename: file_data[:filename],
        type: file_data[:type],
        disposition: 'attachment',
      )
      response.headers['Cache-Control'] = 'no-cache'
    end

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
      if params[:as_of].present?
        Date.parse(params[:as_of])
      else
        Time.zone.yesterday
      end
    end
    helper_method :as_of
  end
end
