module Myott
  class UnsubscribesController < MyottController
    before_action :authentication, except: :confirmation

    def show; end

    def destroy
      success = Subscription.delete(params[:id])
      if success
        redirect_to confirmation_myott_unsubscribes_path
      else
        flash.now[:error] = 'There was an error unsubscribing you. Please try again.'
        render :show
      end
    end

    def confirmation
      cookies.delete(:id_token)
      @header = 'You have unsubscribed'
      @message = 'You will no longer receive any Stop Press emails from the UK Trade Tariff Service.'
    end

  private

    def authentication
      if params[:id].nil? || current_subscription.nil?
        redirect_to myott_start_path
      end
    end
  end
end
