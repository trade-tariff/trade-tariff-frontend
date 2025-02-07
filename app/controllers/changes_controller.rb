class ChangesController < ApplicationController
  def index
    @changes = ChangesPresenter.new(changeable.changes(query_params))

    render atom: @changes
  end

  helper_method :changeable
  helper_method :change_path
end
