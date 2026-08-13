module RulesOfOrigin
  class ProofsController < ApplicationController
    before_action :disable_switch_service_banner, :disable_search_form

    def index
      @schemes = RulesOfOrigin::Scheme.all(include: 'proofs,origin_reference_document')
    end
  end
end
