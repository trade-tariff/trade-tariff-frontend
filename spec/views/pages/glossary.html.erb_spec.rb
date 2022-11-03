require 'spec_helper'

RSpec.describe 'pages/glossary', type: :view do
  subject { render && rendered }

  before do
    assign :glossary, glossary
    stub_template "pages/glossary/_#{page}.html.erb" => '<p>Test page</p>'
  end

  let(:page) { 'test-page' }
  let(:glossary) { instance_double Pages::Glossary, page: "pages/glossary/#{page}" }

  it { is_expected.to have_link 'Back' }
  it { is_expected.to have_css '.govuk-grid-column-two-thirds p', text: 'Test page' }
end
