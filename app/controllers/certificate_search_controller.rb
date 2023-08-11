class CertificateSearchController < ApplicationController
  def new
    @form = CertificateSearchForm.new
    @query = {}
    @certificates = []

    render 'search/certificate_search'
  end

  def create
    @form = CertificateSearchForm.new(certificate_search_params)
    @query = @form.to_params

    @certificates = if @form.valid?
                      Certificate.search(@query)
                    else
                      []
                    end

    render 'search/certificate_search'
  end

  def certificate_search_params
    params.fetch(:certificate_search_form, {}).permit(:code, :description)
  end
end
