module Myott
  class MyottController < ApplicationController
    before_action :disable_search_form,
                  :disable_switch_service_banner,
                  :disable_last_updated_footnote

  private

    def current_user
      @current_user ||= CognitoTokenVerifier.verify_id_token(id_token)
    end

    def id_token
      @id_token ||= begin
        raw_token = cookies[:id_token]
        return nil if raw_token.blank?

        EncryptionService.decrypt_string(raw_token)
      end
    end
  end
end
