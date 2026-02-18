module Myott
  class UnsubscribesController < MyottController
    include UnsubscribesHelper

    skip_before_action :authenticate, only: :confirmation

    def show
      @form = Myott::UnsubscribeMyCommoditiesForm.new if subscription.my_commodities_subscription?
      render subscription.subscription_type_name
    end

    def destroy
      unsubscribe
    end

    def confirmation
      @subscription_type = params[:subscription_type]
      content = unsubscribe_confirmation_content(@subscription_type)
      @title = content[:title]
      @header = content[:header]
      @message = content[:message]
      clear_authentication_cookies
    end

  private

    def authenticate
      if subscription.nil?
        redirect_to myott_start_path
      end
    end

    def subscription
      if params[:id]
        @subscription ||= Subscription.find(params[:id], user_id_token)
      end
    end

    def unsubscribe
      if subscription.my_commodities_subscription?
        handle_my_commodities_unsubscribe
      else
        delete_subscription
      end
    end

    def handle_my_commodities_unsubscribe
      @form = Myott::UnsubscribeMyCommoditiesForm.new(unsubscribe_params)

      return redirect_to myott_mycommodities_path if @form.declined?
      return delete_subscription if @form.confirmed?

      render subscription.subscription_type_name
    end

    def delete_subscription
      if Subscription.delete(params[:id])
        redirect_to confirmation_myott_unsubscribes_path(subscription_type: subscription.subscription_type_name)
      else
        show_deletion_error
      end
    end

    def unsubscribe_params
      params.fetch(:myott_unsubscribe_my_commodities_form, {}).permit(:decision)
    end

    def show_deletion_error
      @alert = 'There was an error unsubscribing you. Please try again.'
      render subscription.subscription_type_name
    end
  end
end
