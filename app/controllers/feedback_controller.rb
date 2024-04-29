class FeedbackController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner,
                :disable_last_updated_footnote

  def new
    session[:feedback_referrer] = request.referer
    @feedback = Feedback.new
    @feedback.page_useful = params[:page_useful]
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.authenticity_token = params[:authenticity_token]
    @feedback.referrer = session[:feedback_referrer]

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
  end

  private

  def feedback_params
    params.require(:feedback).permit(:message, :telephone, :page_useful)
  end
end
