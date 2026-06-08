class FeedbackController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner

  def new
    session[:feedback_referrer] = feedback_url
    session[:feedback_query] = feedback_query
    session[:feedback_request_id] = feedback_request_id
    session[:feedback_date] = feedback_date

    @feedback = Feedback.new
    @feedback.page_useful = params[:page_useful]
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.authenticity_token = params[:authenticity_token]
    @feedback.referrer = session[:feedback_referrer]
    @feedback.query = session[:feedback_query]
    @feedback.request_id = session[:feedback_request_id]
    @feedback.date = session[:feedback_date]

    return redirect_to(find_commodity_path) unless @feedback.valid_page_useful_options?

    if @feedback.valid?
      @feedback.disable_links
      FrontendMailer.new_feedback(@feedback).deliver_now unless @feedback.silently_fail?
      @feedback.record_delivery!

      redirect_to feedback_thanks_path
    else
      render :new
    end
  end

  def thanks
    @referrer = session.delete(:feedback_referrer)
    session.delete(:feedback_query)
    session.delete(:feedback_request_id)
    session.delete(:feedback_date)
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
