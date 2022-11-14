module Pages
  class GlossaryController < ApplicationController
    before_action :disable_search_form,
                  :disable_last_updated_footnote

    def show
      @glossary = Pages::Glossary.find(params[:id])
    end
  end
end
