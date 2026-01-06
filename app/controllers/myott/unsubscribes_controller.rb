module Myott
  class UnsubscribesController < MyottController
    include UnsubscribesHelper

    before_action :authentication, except: :confirmation

    def show
      render subscription_type
    end

    def destroy
      unsubscribe
    end

    def confirmation
      @subscription_type = params[:subscription_type]
      content = unsubscribe_confirmation_content(@subscription_type)
      @header = content[:header]
      @message = content[:message]
      delete_cookie
    end

  private

    def authentication
      if params[:id].nil? || subscription_type.nil?
        redirect_to myott_start_path
      end
    end

    def subscription_type
      @subscription_type ||= Subscription.find(params[:id], user_id_token)&.subscription_type_name
    end

    def my_commodities_subscription?
      subscription_type == Subscription::SUBSCRIPTION_TYPES[:my_commodities]
    end

    def delete_cookie
      domain = ".#{request.host.sub(/^www\./, '')}"
      cookies.delete(:id_token, domain:)
    end

    def unsubscribe
      if my_commodities_subscription?
        handle_my_commodities_unsubscribe
      else
        delete_subscription
      end
    end

    def handle_my_commodities_unsubscribe
      return redirect_to myott_path if user_declined?
      return show_confirmation_error unless user_confirmed?

      delete_subscription
    end

    def delete_subscription
      if Subscription.delete(params[:id])
        redirect_to confirmation_myott_unsubscribes_path(subscription_type: subscription_type)
      else
        show_deletion_error
      end
    end

    def user_declined?
      params[:decision] == 'false'
    end

    def user_confirmed?
      params[:decision] == 'true'
    end

    def show_confirmation_error
      errors = unsubscribe_error_messages
      @alert = errors[:confirmation]
      flash.now[:select_error] = @alert
      render subscription_type
    end

    def show_deletion_error
      errors = unsubscribe_error_messages
      @alert = errors[:deletion]
      render subscription_type
    end
  end
end
