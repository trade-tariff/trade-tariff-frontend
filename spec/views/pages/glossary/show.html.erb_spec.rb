require 'spec_helper'

RSpec.describe 'pages/glossary/show', type: :view do
  subject { render && rendered }

  before { assign :glossary, glossary }

  let(:glossary) { Pages::Glossary.new term }
  let(:term) { 'max_nom' }

  it { is_expected.to have_link 'Back' }
  it { is_expected.to have_css '.govuk-grid-column-two-thirds p', text: /NOM/i }
end
