require 'spec_helper'

RSpec.describe 'pages/glossary/index', type: :view do
  subject { render && rendered }

  before { assign :terms, Pages::Glossary.all }

  it { is_expected.to have_css '.govuk-caption-xl', text: /guide/i }
  it { is_expected.to have_css 'h1', text: /glossary/i }

  it { is_expected.to have_css '#contents h2', text: /contents/i }
  it { is_expected.to have_css '#contents ol li a', count: Pages::Glossary.all.length }

  it { is_expected.to have_css '.govuk-grid-column-two-thirds h3', text: Pages::Glossary::PAGES.values.first }
  it { is_expected.to have_css '.govuk-grid-column-two-thirds h3', text: Pages::Glossary::PAGES.values.last }

  it { is_expected.to have_css '.govuk-grid-column-one-third a' }
end
