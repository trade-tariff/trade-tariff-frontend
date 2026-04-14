module Pages
  class GlossaryController < ApplicationController
    before_action :disable_search_form

    def index
      @terms = Pages::Glossary.all
    end

    def show
      @glossary = Pages::Glossary.find(params[:id])
    end
  end
end
