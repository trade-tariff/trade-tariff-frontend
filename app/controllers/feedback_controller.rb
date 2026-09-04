class FeedbackController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner

  def new
    @feedback = Feedback.new
    @feedback.page_useful = params[:page_useful]
    @feedback.referrer = feedback_url
    @feedback.query = feedback_query
    @feedback.request_id = feedback_request_id
    @feedback.date = feedback_date
    @feedback.feature_flags = feedback_feature_flags
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.authenticity_token = params[:authenticity_token]
    @feedback.referrer = params[:feedback_url]
    @feedback.query = params[:feedback_query]
    @feedback.request_id = params[:feedback_request_id]
    @feedback.date = params[:feedback_date]
    @feedback.feature_flags = feedback_feature_flags

    return redirect_to(find_commodity_path) unless @feedback.valid_page_useful_options?

    if @feedback.valid?
      @feedback.disable_links
      FrontendMailer.new_feedback(@feedback).deliver_now unless @feedback.silently_fail?
      @feedback.record_delivery!

      redirect_to feedback_thanks_path(feedback_url: @feedback.referrer)
    else
      render :new
    end
  end

  def thanks
    @referrer = params[:feedback_url]
  end

  private

  def feedback_params
    params.require(:feedback).permit(:message, :telephone, :page_useful)
  end

  def feedback_url
    params[:feedback_url].presence || request.referer
  end

  def feedback_query
    params[:feedback_query].presence || referrer_query_param('q')
  end

  def feedback_request_id
    params[:feedback_request_id].presence || referrer_query_param('request_id')
  end

  def referrer_query_param(key)
    referrer_query_params[key]
  end

  def referrer_query_params
    return {} if request.referer.blank?

    uri = URI.parse(request.referer)
    Rack::Utils.parse_query(uri.query || '')
  rescue URI::InvalidURIError
    {}
  end

  def feedback_date
    params[:feedback_date].presence || referrer_date_param
  end

  def feedback_feature_flags
    return TradeTariffFrontend.enabled_flagsmith_feature_names unless params.key?(:feedback_feature_flags)

    registered_names = TradeTariffFrontend::Config.registered_flags.values.pluck(:name)
    params[:feedback_feature_flags].to_s.split(',') & registered_names
  end

  def referrer_date_param
    referrer_date_from_day_month_year.presence || referrer_query_param('as_of')
  end

  def referrer_date_from_day_month_year
    return unless referrer_query_params.values_at('day', 'month', 'year').all?(&:present?)

    TariffDate.build(referrer_query_params.slice('year', 'month', 'day')).to_fs(:db)
  rescue Date::Error
    nil
  end
end
