module Myott
  class MycommoditiesController < MyottController
    before_action :authenticate, only: %i[new create index]
    before_action :initialize_subscription_data

    require 'csv'
    require 'roo'

    VALID_FILE_TYPES = [
      'text/csv',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ].freeze

    def new
      Rails.cache.delete(session[:commodity_codes_key]) if session[:commodity_codes_key].present?
      session.delete(:commodity_codes_key)
    end

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
      my_commodities_subscription = get_subscription('my_commodities')
      redirect_to new_myott_mycommodity_path and return unless my_commodities_subscription

      meta = my_commodities_subscription[:meta]

      cache_session_commodity_codes({ 'active_commodity_codes' => meta['active'],
                                      'expired_commodity_codes' => meta['expired'],
                                      'invalid_commodity_codes' => meta['invalid'] })

      codes = Rails.cache.read(session[:commodity_codes_key])

      @active_commodity_codes ||= codes['active_commodity_codes']
      @expired_commodity_codes ||= codes['expired_commodity_codes']
      @invalid_commodity_codes ||= codes['invalid_commodity_codes']

      @total_commodity_codes = codes.values.flatten.size
    end

    def create
      file = validate_file(params[:fileUpload1])
      return unless file

      commodity_codes = extract_codes_from_file(file)

      if commodity_codes.blank?
        @alert = 'No commodities uploaded, please ensure valid commodity codes are in column A'
        render :new and return
      end
      update_user_commodity_codes(commodity_codes)
      redirect_to myott_mycommodities_path
    end

    private

    def initialize_subscription_data
      session[:commodity_codes_key] ||= {}
    end

    def update_user_commodity_codes(commodity_codes)
      subscription = get_subscription('my_commodities')

      subscription_id = if subscription.nil? && User.update(cookies[:id_token], my_commodities_subscription: 'true')
                          get_subscription('my_commodities').resource_id
                        else
                          subscription.resource_id
                        end
      Subscription.batch(subscription_id,
                         user_id_token,
                         targets: TariffJsonapiParser.new(commodity_codes.uniq).parse,
                         subscription_type: 'my_commodities')
    end

    def extract_codes_from_file(file)
      # we are assuming that first column in each row is a candidate commodity code,
      # we are assuming that if excel the first sheet has the data
      first_column_values =
        case file.content_type
        when 'text/csv'
          CSV.parse(file.read).map { |row| row[0] }
        else
          Roo::Spreadsheet.open(file).sheet(0).map { |row| row[0] }
        end

      first_column_values.filter_map do |value|
        code = parse_numbers_only(value.to_s)
        code if candidate_commodity_code?(code)
      end
    end

    def cache_session_commodity_codes(commodity_codes)
      redis_key = "submission:commodity_codes:#{session.id}"
      Rails.cache.write(redis_key, commodity_codes, expires_in: 1.hour)
      session[:commodity_codes_key] = redis_key
    end

    def parse_numbers_only(string)
      string.gsub(/[^0-9]/, '').strip
    end

    def candidate_commodity_code?(code)
      code.present? && code.length.between?(1, 20)
    end

    def validate_file(file)
      if file.blank?
        @alert = 'Please upload a file using the Choose file button or drag and drop.'
        render :new and return nil
      end

      unless VALID_FILE_TYPES.include?(file.content_type)
        @alert = 'please upload a csv/excel file'
        render :new and return nil
      end

      file
    end

    def get_subscription_targets(category)
      subscription_id = get_subscription('my_commodities').resource_id

      page = params[:page].presence || 1
      per_page = params[:per_page].presence || 10

      params = { filter: { active_commodities_type: category },
                 page: page,
                 per_page: per_page }
      my_commodities = SubscriptionTarget.all(subscription_id, params)
      @commodities = my_commodities
      @total_commodities_count = my_commodities.total_count
      @category = category.capitalize

      render :list
    end
  end
end
