require 'spec_helper'

RSpec.describe 'measures/grouped/_table', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let(:render_page) do
    render 'measures/grouped/table',
           caption: 'Import duties',
           collection: [],
           css_id: 'import_duties',
           declarable: declarable,
           import_duties: true,
           standard_collection: [],
           preferential_collection: [],
           roo_schemes: [],
           show_duty_calculator: show_duty_calculator
  end

  let(:declarable) { instance_double(Heading, code: '1704000000') }
  let(:show_duty_calculator) { true }

  it 'renders the duty calculator link when show_duty_calculator is true' do
    expect(rendered_page).to have_css '#duty-calculator-link[href="/duty-calculator/1704000000/import-date"]',
                                      text: 'Start a duty calculation'
  end

  it 'renders the decorative calculator icon at the required size' do
    expect(rendered_page).to have_css 'img.measure-inset--calculator__icon[src*="calculator-icon"][alt=""][width="41"][height="50"]'
  end

  it 'renders the decorative arrow icon inside the calculator link at the required size' do
    expect(rendered_page).to have_css '#duty-calculator-link img.measure-inset--calculator__arrow[src*="arrow-icon"][alt=""][width="30"][height="30"]'
  end

  context 'when show_duty_calculator is false' do
    let(:show_duty_calculator) { false }

    it 'does not render the duty calculator link' do
      expect(rendered_page).not_to have_css '#duty-calculator-link'
    end
  end
end
