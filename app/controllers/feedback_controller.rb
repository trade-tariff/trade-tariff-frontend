class FeedbackController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner

  def new
    session[:feedback_referrer] = feedback_url
    session[:feedback_query] = feedback_query
    session[:feedback_request_id] = feedback_request_id

    @feedback = Feedback.new
    @feedback.page_useful = params[:page_useful]
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.authenticity_token = params[:authenticity_token]
    @feedback.referrer = session[:feedback_referrer]
    @feedback.query = session[:feedback_query]
    @feedback.request_id = session[:feedback_request_id]

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
    return if request.referer.blank?

    uri = URI.parse(request.referer)
    Rack::Utils.parse_query(uri.query)[key]
  rescue URI::InvalidURIError
    nil
  end
end
