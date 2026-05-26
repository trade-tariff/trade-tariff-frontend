require 'spec_helper'

RSpec.describe 'Revised enquiry form flow', :aggregate_failures, type: :feature do
  around do |example|
    old_store = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rails.cache = old_store
  end

  before do
    allow(EnquiryForm).to receive(:create!)
      .and_return({ 'resource_id' => 'HDJ2123F' })
  end

  it 'lets a user complete the classification journey with large goods details' do
    visit product_experience_enquiry_form_path

    expect(page).to have_css 'h1', text: 'What do you need help with?'
    expect(page).not_to have_css '.feedback-useful-banner'

    click_button 'Continue'
    expect(page).to have_content 'Please select what you need help with.'
    expect(page).to have_current_path(product_experience_enquiry_form_field_path('category'), ignore_query: true)

    choose 'Classification'
    expect(page).to have_checked_field 'Classification'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Tell us about your goods'
    expect(page).to have_current_path(product_experience_enquiry_form_field_path('goods_details'), ignore_query: true)

    fill_in 'What is the product?', with: large_answer('A detailed description of embroidered floss')
    fill_in 'What is it made of?', with: large_answer('Cotton thread and synthetic packaging')
    fill_in 'What is it used for? (optional)', with: large_answer('Used for embroidery and craft projects')
    fill_in 'How does it work or function? (optional)', with: large_answer('It is threaded through a needle by hand')
    fill_in 'Has it been processed, prepared or treated in any way? (optional)', with: large_answer('It has been dyed and wound onto skeins')
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Do you already have a possible commodity code?'

    choose 'Yes'
    fill_in 'Possible commodity code', with: '5204200010'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Contact details'

    fill_in 'Email address', with: 'trader@example.com'
    fill_in 'Name (optional)', with: 'Joan Georgia'
    fill_in 'Company name (optional)', with: 'Fabulous Embroidery Ltd.'
    fill_in 'Job title (optional)', with: 'Director'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Check your answers before submitting your form'
    expect(page).to have_content 'Classification'
    expect(page).to have_content 'A detailed description of embroidered floss'
    expect(page).to have_content 'Cotton thread and synthetic packaging'
    expect(page).to have_content '5204200010'
    expect(page).to have_content 'trader@example.com'

    click_button 'Submit'

    expect(page).to have_css 'h1', text: 'Your request has been submitted'
    expect(page).to have_content 'HDJ2123F'
    expect(page).to have_content 'Please make a note of your reference number.'
    expect(page).to have_css '.feedback-useful-banner'

    expect(EnquiryForm).to have_received(:create!).with(
      hash_including(
        email: 'trader@example.com',
        enquiry_category: 'classification',
        goods_product: include('A detailed description of embroidered floss'),
        goods_made_of: include('Cotton thread and synthetic packaging'),
        commodity_code: '5204200010',
      ),
    )
  end

  it 'lets a user complete the generic enquiry journey' do
    visit product_experience_enquiry_form_path

    choose 'Import Duties and Quota'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'How can we help you?'

    fill_in 'How can we help you?', with: 'I need help understanding tariff quota duties.'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Contact details'

    fill_in 'Email address', with: 'trader@example.com'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Check your answers before submitting your form'
    expect(page).to have_content 'Import Duties and Quota'
    expect(page).to have_content 'I need help understanding tariff quota duties.'
    expect(page).to have_content 'trader@example.com'

    click_button 'Submit'

    expect(page).to have_css 'h1', text: 'Your request has been submitted'

    expect(EnquiryForm).to have_received(:create!).with(
      hash_including(
        email: 'trader@example.com',
        enquiry_category: 'import_duties_and_quota',
        enquiry_description: 'I need help understanding tariff quota duties.',
      ),
    )
  end

  it 'validates category and goods detail required fields without losing the journey' do
    visit product_experience_enquiry_form_path

    click_button 'Continue'

    expect(page).to have_current_path(product_experience_enquiry_form_field_path('category'), ignore_query: true)
    expect(page).to have_css 'h1', text: 'What do you need help with?'
    expect(page).to have_content 'Please select what you need help with.'

    choose 'Classification'
    click_button 'Continue'

    click_button 'Continue'

    expect(page).to have_current_path(product_experience_enquiry_form_field_path('goods_details'), ignore_query: true)
    expect(page).to have_css 'h1', text: 'Tell us about your goods'
    expect(page).to have_content 'Please describe the product.'
    expect(page).to have_content 'Please say what the product is made of.'
  end

  it 'requires a short label when the user selects other' do
    visit product_experience_enquiry_form_path

    choose 'Other'
    click_button 'Continue'

    expect(page).to have_current_path(product_experience_enquiry_form_field_path('category'), ignore_query: true)
    expect(page).to have_content 'Please add a short label.'

    fill_in 'Add a short label. You can explain it fully on the next page', with: 'Question about a tariff tool feature'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'How can we help you?'
  end

  def large_answer(prefix)
    "#{prefix}. #{'Extra detail ' * 350}"
  end
end
