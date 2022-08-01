module Beta
  class SearchController < ApplicationController
    def search
      skip_before_action :set_search

      respond_to do |format|
        format.html do
          render '/beta/search/search'
        end
      end
    end
  end
end
