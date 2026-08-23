RSpec.describe 'Guided VAT within the duty calculator', :user_session, type: :feature do
  let(:user_session) do
    build(
      :duty_calculator_user_session,
      :with_commodity_information,
      :with_import_date,
      :with_import_destination,
      :with_country_of_origin,
      :with_customs_value,
      commodity_code: '2005202000',
    )
  end
  let(:commodity) { build(:duty_calculator_commodity, goods_nomenclature_item_id: '2005202000') }
  let(:commodity_context_service) { instance_double(DutyCalculator::CommodityContextService, call: commodity) }

  before do
    stub_vat_guidance_demo
    allow(DutyCalculator::CommodityContextService).to receive(:new).and_return(commodity_context_service)
  end

  it 'returns a commodity-specific result to the VAT step for explicit confirmation', :aggregate_failures do
    visit vat_path

    expect(page).to have_css('h1', text: 'Which VAT rate is applicable to your trade?')
    expect(page).to have_text('VAT Notice 709/1 — catering and food exceptions')
    first(:button, 'Start this guidance').click

    expect(page).to have_css('h1', text: 'Is the product supplied in the course of catering?')
    choose 'No'
    click_button 'Continue'

    expect(page).to have_css('h1', text: 'Is the product packaged and ready to eat?')
    choose 'Yes'
    click_button 'Continue'

    expect(page).to have_css('h1', text: 'Guided VAT result')
    expect(page).to have_text('Zero')
    expect(page).to have_text('VATZ')
    expect(page).to have_text('not an HMRC determination')
    expect(page).to have_link('Read the source guidance', href: %r{gov\.uk/guidance/food-products})

    click_link 'Return to VAT rate selection'

    expect(page).to have_text('Guided VAT result: VAT zero rate (0.0)')
    expect(page).to have_checked_field('VAT zero rate (0.0)')
    click_button 'Continue'

    expect(page).to have_current_path(confirm_path)
    expect(user_session.vat).to eq('VATZ')
  end

  it 'does not expose the removed standalone prototype URL' do
    visit '/vat-guidance-prototype'

    expect(page.status_code).to eq(404)
  end
end
