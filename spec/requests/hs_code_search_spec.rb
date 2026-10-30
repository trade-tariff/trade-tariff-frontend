require 'spec_helper'

RSpec.describe 'HS code searches', :aggregate_failures, type: :request do
  def stub_code_search(query, endpoint: nil, id: nil)
    payload = if hybrid
                { data: if endpoint
                          [{
                            id:,
                            type: endpoint.singularize,
                            attributes: {
                              goods_nomenclature_item_id: id.split('-').first,
                              producline_suffix: '80',
                              goods_nomenclature_class: endpoint.singularize.camelize,
                              description: 'Computers',
                              declarable: endpoint == 'commodities',
                            },
                          }]
                        else
                          []
                        end }
              elsif endpoint
                format_jsonapi_response(:search, { type: 'exact_match', entry: { endpoint:, id: } })
              else
                empty_match = { chapters: [], headings: [], commodities: [], sections: [] }
                format_jsonapi_response(:search, { type: 'fuzzy_match', goods_nomenclature_match: empty_match, reference_match: empty_match })
              end

    stub_api_request('search', :post, internal: hybrid)
      .with { |request|
        body = hybrid ? JSON.parse(request.body) : URI.decode_www_form(request.body).to_h
        body['q'] == query && body['as_of'] == '2026-10-14' && body['request_id'] == 'hs-code-request'
      }
      .to_return(status: 200, body: payload.to_json, headers: { 'content-type' => 'application/json' })
  end

  def submit_search(term, method: :get)
    filters = { 'as_of(1i)' => '2026', 'as_of(2i)' => '10', 'as_of(3i)' => '14' }
    params = { request_id: 'hs-code-request', country: 'FR' }
    params.merge!(method == :post ? { search: filters.merge(q: term) } : { q: term, search: filters })
    public_send(method, "/#{service}/search", params:)
  end

  def expect_missing_commodity(id)
    %W[commodities/#{id} subheadings/#{id}-80].each do |endpoint|
      stub_api_request(endpoint).with(query: hash_including('as_of' => '2026-10-14')).to_return(jsonapi_not_found_response)
    end
    stub_api_request("commodities/#{id}/validity_periods").with(query: { as_of: '2026-10-14' }).to_return(jsonapi_response(:validity_period, []))
    follow_redirect!

    expect(response).to have_http_status(:not_found)
    expect(Capybara.string(response.body)).to have_text("The commodity code you searched for can't be found. Try searching again.")
  end

  %w[uk xi].each do |service_name|
    context "with #{service_name}" do
      let(:service) { service_name }

      before { TradeTariffFrontend::ServiceChooser.service_choice = service }

      [false, true].each do |hybrid_enabled|
        context "with #{hybrid_enabled ? 'hybrid' : 'classic V2'} search" do
          let(:hybrid) { hybrid_enabled }

          before do
            hybrid ? enable_feature(:hybrid_search) : disable_feature(:hybrid_search)
          end

          {
            'HS:8471' => %w[8471 headings 8471],
            'HS 8471.30' => %w[847130 subheadings 8471300000-80],
            '8471.30.00' => %w[84713000 subheadings 8471300000-80],
            'HS 8471.30.00.00' => %w[8471300000 commodities 8471300000],
            '8471 30 00 00' => %w[8471300000 commodities 8471300000],
            "HS\u00a08471300000" => %w[8471300000 commodities 8471300000],
            "8471\u00a030\u00a000\u00a000" => %w[8471300000 commodities 8471300000],
            "\u00a08471300000\u00a0" => %w[8471300000 commodities 8471300000],
            "\u00a0HS 8471300000\u00a0" => %w[8471300000 commodities 8471300000],
          }.each do |term, (digits, endpoint, id)|
            %i[get post].each do |method|
              it "routes #{method.upcase} #{term.inspect} like #{digits} and sends canonical digits" do
                stub = stub_code_search(digits, endpoint:, id:)
                submit_search(digits, method:)
                expect(stub).to have_been_requested
                expect(response).to redirect_to(public_send("#{endpoint.singularize}_path", id, day: '14', month: '10', year: '2026', country: 'FR', request_id: 'hs-code-request'))
                control_location = response.location

                # A warm hybrid cache must not hide the formatted query at the API boundary.
                Rails.cache.clear
                submit_search(term, method:)

                expect(stub).to have_been_requested.twice
                expect(response).to redirect_to(control_location)
              end
            end
          end

          {
            'HS 8708.50.2099' => %w[8708502099 commodity 8708502099],
            'HS 8471' => %w[8471 heading 8471],
            'HS 8471.00.00.00' => %w[8471000000 heading 8471],
          }.each do |term, (digits, destination, id)|
            it "keeps the plain-digit fallback for #{term.inspect}" do
              stub = stub_code_search(digits)
              submit_search(digits)
              expect(stub).to have_been_requested
              expect(response).to redirect_to(public_send("#{destination}_path", id, day: '14', month: '10', year: '2026', country: 'FR', request_id: 'hs-code-request'))
              control_location = response.location
              expect_missing_commodity(id) if destination == 'commodity'
              Rails.cache.clear
              submit_search(term)

              expect(stub).to have_been_requested.twice
              expect(response).to redirect_to(control_location)

              expect_missing_commodity(id) if destination == 'commodity'
            end
          end

          [
            'laptop',
            'HS',
            'hose',
            '1.5 litre bottle',
            'HS 847',
            'HS 84713',
            'HSN 8471',
            'HTS 8471',
            'HS code:8471',
            '8471-30',
            '8471/30',
            "HS 8471\t30",
            "HS\t847130",
            "laptop\u00a0computer",
            "\u00a0laptop\u00a0",
          ].each do |term|
            it "preserves #{term.inspect} at the API boundary" do
              stub = stub_code_search(term)
              submit_search(term)

              expect(stub).to have_been_requested
              expect(response).to have_http_status(:ok)
              expect(Capybara.string(response.body)).to have_text('There are no results matching your query')
            end
          end
        end
      end
    end
  end
end
