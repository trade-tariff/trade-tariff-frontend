require 'spec_helper'

RSpec.describe 'measures/grouped/_table', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let(:render_page) do
    render 'measures/grouped/table',
           caption: 'Import duties',
           collection: [],
           css_id: 'import_duties',
           declarable: declarable,
           show_duty_calculator: show_duty_calculator
  end

  let(:declarable) { instance_double(Heading, code: '1704000000') }
  let(:show_duty_calculator) { true }

  it 'renders the duty calculator link when show_duty_calculator is true' do
    expect(rendered_page).to have_css '#duty-calculator-link[href="/duty-calculator/1704000000/import-date"]',
                                      text: 'work out the duties and taxes applicable to the import of commodity 1704 0000 00'
  end

  context 'when show_duty_calculator is false' do
    let(:show_duty_calculator) { false }

    it 'does not render the duty calculator link' do
      expect(rendered_page).not_to have_css '#duty-calculator-link'
    end
  end
end
