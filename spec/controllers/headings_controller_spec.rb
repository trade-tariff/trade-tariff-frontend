require 'spec_helper'

describe HeadingsController, "GET to #show", :webmock do
  let!(:heading)     { Heading.new(attributes_for :heading) }
  let!(:actual_date) { Date.today.to_s(:dashed) }

  before(:each) do
    stub_request(:get, "http://www.example.com/api/headings/#{heading.short_code}?as_of=#{actual_date}").
           to_return(status: 200,
                     body: File.read("spec/fixtures/responses/headings_show.json"),
                     headers: { content_type: 'application/json' })

    get :show, id: heading.short_code
  end

  it { should respond_with(:success) }
  it { should assign_to(:heading) }
  it { should assign_to(:commodities) }
end
