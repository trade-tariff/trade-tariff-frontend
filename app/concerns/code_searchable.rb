module CodeSearchable
  extend ActiveSupport::Concern

  included do
    def new
      @form = self.class.form_class.new
      @query = {}
      instance_variable_set(self.class.results_ivar, [])
      render self.class.search_template
    end

    def create
      @form = self.class.form_class.new(search_form_params)
      @query = @form.to_params
      instance_variable_set(self.class.results_ivar, @form.valid? ? self.class.model_class.search(@query) : [])
      render self.class.search_template
    end

    private

    def search_form_params
      params.fetch(self.class.form_param_key, {}).permit(:code, :description)
    end
  end
end
