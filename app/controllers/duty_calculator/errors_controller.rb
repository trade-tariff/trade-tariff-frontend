module DutyCalculator
  class ErrorsController < ApplicationController
    layout 'application'

    helper_method :user_session

    def bad_request
      message = "The request you made is not valid.<br>
               Please contact support for assistance or try a different request.".html_safe

      respond_to do |format|
        format.html { render 'error', status: :bad_request, locals: { header: 'Bad request', message: } }
        format.json { render json: { error: 'Bad request' }, status: :bad_request }
        format.all { render status: :bad_request, plain: 'Bad request' }
      end
    end

    def not_found
      message = 'You may have mistyped the address or the page may have moved.'

      respond_to do |format|
        format.html { render 'error', status: :not_found, locals: { header: 'The page you were looking for does not exist.', message: } }
        format.json { render json: { error: 'Resource not found' }, status: :not_found }
        format.all { render status: :not_found, plain: 'Resource not found'  }
      end
    end

    def method_not_allowed
      message = "We're sorry, but this request method is not supported.<br>
                Please contact support for assistance or try a different request.".html_safe

      respond_to do |format|
        format.html { render 'error', status: :method_not_allowed, locals: { header: 'Method not allowed', message: } }
        format.json { render json: { error: 'Method not allowed' }, status: :method_not_allowed }
        format.all { render status: :method_not_allowed, plain: 'Bad request' }
      end
    end

    def not_acceptable
      message = "Unfortunately, we cannot fulfill your request as it is not in a format we can accept.<br>
                Please contact support for assistance or try a different request.".html_safe

      respond_to do |format|
        format.html { render 'error', status: :not_acceptable, locals: { header: 'Not acceptable', message: } }
        format.json { render json: { error: 'Not acceptable' }, status: :not_acceptable }
        format.all { render status: :not_acceptable, plain: 'Not accepdtable' }
      end
    end

    def unprocessable_entity
      message = "Maybe you tried to change something you didn't have access to."

      respond_to do |format|
        format.html do
          render 'error', status: :unprocessable_entity,
                          locals: { header: 'The change you wanted was rejected.', message: }
        end
        format.json { render json: { error: 'Unprocessable entity' }, status: :unprocessable_entity }
        format.all { render status: :unprocessable_entity, plain: 'Unprocessable entity' }
      end
    end

    def internal_server_error
      message = 'We could not proceed with calculating your duty.'

      respond_to do |format|
        format.html do
          render 'error', status: :internal_server_error,
                          locals: { header: 'Sorry, there is a problem with the service', message: }
        end
        format.json { render json: { error: 'Internal server error' }, status: :internal_server_error }
        format.all { render status: :internal_server_error, plain: 'Internal server error' }
      end
    end

    def not_implemented
      message = 'We\'re sorry, but the requested action is not supported by our server at this time.<br>
               Please contact support for assistance or try a different request.'.html_safe

      respond_to do |format|
        format.html { render 'error', status: :not_implemented, locals: { header: 'Not implemented', message: } }
        format.json { render json: { error: 'Not implemented' }, status: :not_implemented }
        format.all { render status: :not_implemented, plain: 'Not Implemented' }
      end
    end
  end
end
