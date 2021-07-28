require 'addressable/uri'

class SearchController < ApplicationController
  def search
    @results = @search.perform

    respond_to do |format|
      format.html do
        if @search.contains_search_term?
          redirect_to url_for(@results.to_param.merge(url_options)) if @results.exact_match?
        else
          if request.referer
            back_url = Addressable::URI.parse(request.referer)
            back_url.query_values ||= {}
            back_url.query_values = back_url.query_values.merge(@search.query_attributes)
            if @search.date.today?
              back_url.query_values = back_url.query_values.except('year', 'month', 'day')
            end
            return_to = back_url.to_s
          else
            return_to = sections_url
          end

          redirect_to(return_to + anchor)
        end
      end

      format.json do
        render json: SearchPresenter.new(@search, @results)
      end

      format.atom
    end
  end

  def suggestions
    search_term = Regexp.escape(params[:term].to_s)
    start_with = SearchSuggestion.start_with(search_term).sort_by(&:value)
    results = start_with.map { |s| { id: s.value, text: s.value } }

    render json: { results: results }
  end

  def quota_search
    render_404 if TradeTariffFrontend::ServiceChooser.xi?

    form = QuotaSearchForm.new(params)
    @result = QuotaSearchPresenter.new(form)
    @enable_service_switch_banner_in_action = false
    @no_shared_switch_service_link = true

    respond_to do |format|
      format.html
    end
  end

  def additional_code_search
    form = AdditionalCodeSearchForm.new(params)
    @result = AdditionalCodeSearchPresenter.new(form)
    @no_shared_switch_service_link = true
    respond_to do |format|
      format.html
    end
  end

  def footnote_search
    form = FootnoteSearchForm.new(params)
    @result = FootnoteSearchPresenter.new(form)
    respond_to do |format|
      format.html
    end
  end

  def certificate_search
    form = CertificateSearchForm.new(params)
    @result = CertificateSearchPresenter.new(form)
    @no_shared_switch_service_link = true
    respond_to do |format|
      format.html
    end
  end

  def chemical_search
    form = ChemicalSearchForm.new(params)
    @result = ChemicalSearchPresenter.new(form)
    @no_shared_switch_service_link = true
    respond_to do |format|
      format.html
    end
  end

  private

  def anchor
    safe_anchor = params.dig(:search, :anchor).to_s.gsub(/[^a-z]/, '')
    safe_anchor.present? ? "##{safe_anchor}" : ''
  end
end
