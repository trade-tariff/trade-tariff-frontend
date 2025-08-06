class BasicSessionsController < ApplicationController
  skip_before_action :require_authentication, only: %i[new create]

  before_action :disable_switch_service_banner,
                :disable_last_updated_footnote,
                :disable_search_form

  def new
    @basic_session = BasicSession.new
    @basic_session.return_url = params[:return_url] || root_path
  end

  def create
    @basic_session = BasicSession.new(basic_session_params)

    if @basic_session.valid?
      session[:authenticated] = true
      redirect_to @basic_session.return_url
    else
      render :new
    end
  end

  def basic_session_params
    params.require(:basic_session).permit(:return_url, :password)
  end
end
