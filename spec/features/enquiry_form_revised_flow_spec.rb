require 'spec_helper'

RSpec.describe 'Revised enquiry form flow', :aggregate_failures, type: :feature do
  let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }

  around do |example|
    old_cache_store = ProductExperience::EnquiryFormDraftStore.instance_variable_get(:@cache_store)
    ProductExperience::EnquiryFormDraftStore.cache_store = cache_store
    example.run
  ensure
    ProductExperience::EnquiryFormDraftStore.cache_store = old_cache_store
  end

  before do
    allow(EnquiryForm).to receive(:create!)
      .and_return({ 'resource_id' => 'HDJ2123F' })
  end

  it 'lets a user complete the classification journey with large goods details', :js do
    visit product_experience_enquiry_form_path

    expect(page).to have_css 'h1', text: 'What do you need help with?'
    expect(page).not_to have_css '.feedback-useful-banner'
    expect(page).to have_content 'Use this form if you need help from the HMRC Trade Tariff team. Choose the option that best matches your question so it goes to the right team.'
    expect(page).to have_css 'label.govuk-radios__label.govuk-\\!-font-weight-bold', text: 'Classification'
    expect(page).to have_css '.govuk-radios__hint', text: 'Help finding the correct commodity code for your goods.'

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
    expect(page).to have_link('Change', count: 4)
    expect(session_cookie_value.length).to be < 3500
    expect(session_cookie_value).not_to include('A detailed description of embroidered floss')

    page.go_back
    expect(page).to have_css 'h1', text: 'Contact details'
    expect(page).to have_field 'Email address', with: 'trader@example.com'

    page.go_back
    expect(page).to have_css 'h1', text: 'Do you already have a possible commodity code?'
    expect(page).to have_checked_field 'Yes'
    expect(page).to have_field 'Possible commodity code', with: '5204200010'

    page.go_back
    expect(page).to have_css 'h1', text: 'Tell us about your goods'
    expect(find_field('What is the product?').value).to include('A detailed description of embroidered floss')
    expect(find_field('What is it made of?').value).to include('Cotton thread and synthetic packaging')

    click_button 'Continue'
    click_button 'Continue'
    click_button 'Continue'

    click_button 'Submit'

    expect(page).to have_css 'h1', text: 'Your request has been submitted'
    expect(page).to have_content 'HDJ2123F'
    expect(page).to have_content 'Please make a note of your reference number.'
    expect(page).to have_css 'h2', text: 'Other ways to find information'
    expect(page).to have_link 'Help section', href: help_path
    expect(page).to have_link 'Live issues log', href: live_issues_path
    expect(page).to have_css '#enquiry-form-confirmation-help-link[data-controller="analytics"][data-action="click->analytics#track"][data-analytics-event="confirmation_help_clicked"]'
    expect(page).to have_css '#enquiry-form-confirmation-live-issues-link[data-controller="analytics"][data-action="click->analytics#track"][data-analytics-event="confirmation_live_issues_clicked"]'
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

    choose 'Import duties and quotas'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'How can we help you?'

    fill_in 'How can we help you?', with: large_answer('I need help understanding tariff quota duties')
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Contact details'

    fill_in 'Email address', with: 'trader@example.com'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Check your answers before submitting your form'
    expect(page).to have_content 'Import duties and quotas'
    expect(page).to have_content 'I need help understanding tariff quota duties.'
    expect(page).to have_content 'trader@example.com'

    click_button 'Submit'

    expect(page).to have_css 'h1', text: 'Your request has been submitted'

    expect(EnquiryForm).to have_received(:create!).with(
      hash_including(
        email: 'trader@example.com',
        enquiry_category: 'import_duties_and_quota',
        enquiry_description: include('I need help understanding tariff quota duties'),
      ),
    )
  end

  it 'clears a possible commodity code when the user changes their answer to no' do
    visit product_experience_enquiry_form_path

    choose 'Classification'
    click_button 'Continue'

    fill_in 'What is the product?', with: 'Steel bar'
    fill_in 'What is it made of?', with: 'Steel'
    click_button 'Continue'

    choose 'Yes'
    fill_in 'Possible commodity code', with: '9403208090'
    choose 'No'
    click_button 'Continue'

    fill_in 'Email address', with: 'trader@example.com'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Check your answers before submitting your form'
    expect(page).to have_content 'Do you already have a possible commodity code?'
    expect(page).to have_content 'No'
    expect(page).not_to have_content 'Possible commodity code'
    expect(page).not_to have_content '9403208090'

    click_button 'Submit'

    expect(page).to have_css 'h1', text: 'Your request has been submitted'

    expect(EnquiryForm).to have_received(:create!).with(
      satisfy do |attributes|
        expect(attributes).to include(
          email: 'trader@example.com',
          enquiry_category: 'classification',
          goods_product: 'Steel bar',
          goods_made_of: 'Steel',
          has_commodity_code: 'no',
        )
        expect(attributes).not_to include(:commodity_code)
      end,
    )
  end

  it 'clears route-specific answers and collects required answers when the category route changes from check answers' do
    visit product_experience_enquiry_form_path

    choose 'Classification'
    click_button 'Continue'

    fill_in 'What is the product?', with: 'Embroidery floss'
    fill_in 'What is it made of?', with: 'Cotton thread'
    click_button 'Continue'

    choose 'Yes'
    fill_in 'Possible commodity code', with: '5204200010'
    click_button 'Continue'

    fill_in 'Email address', with: 'trader@example.com'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Check your answers before submitting your form'
    expect(page).to have_content 'Embroidery floss'

    within first('.govuk-summary-list__row', text: 'What do you need help with?') do
      click_link 'Change'
    end

    choose 'Valuation'
    click_button 'Continue'

    expect(page).to have_current_path(product_experience_enquiry_form_field_path('query'), ignore_query: true)
    expect(page).to have_css 'h1', text: 'How can we help you?'

    fill_in 'How can we help you?', with: 'I need help with customs valuation.'
    click_button 'Continue'

    expect(page).to have_current_path(product_experience_enquiry_form_field_path('contact_details'), ignore_query: true)
    expect(page).to have_css 'h1', text: 'Contact details'
    expect(page).to have_field 'Email address', with: 'trader@example.com'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'Check your answers before submitting your form'
    expect(page).to have_content 'Valuation'
    expect(page).to have_content 'I need help with customs valuation.'
    expect(page).not_to have_content 'Embroidery floss'
    expect(page).not_to have_content '5204200010'

    click_button 'Submit'

    expect(page).to have_css 'h1', text: 'Your request has been submitted'

    expect(EnquiryForm).to have_received(:create!).with(
      satisfy do |attributes|
        expect(attributes).to include(
          email: 'trader@example.com',
          enquiry_category: 'valuation',
          enquiry_description: 'I need help with customs valuation.',
        )
        expect(attributes).not_to include(
          :goods_product,
          :goods_made_of,
          :has_commodity_code,
          :commodity_code,
        )
      end,
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
    expect(page).to have_css '#goods_product.govuk-input--error[aria-describedby="goods_product-hint goods_product-error"]'
    expect(page).to have_css '#goods_made_of.govuk-input--error[aria-describedby="goods_made_of-hint goods_made_of-error"]'
  end

  it 'requires a short label when the user selects other' do
    visit product_experience_enquiry_form_path

    choose 'Other'
    click_button 'Continue'

    expect(page).to have_current_path(product_experience_enquiry_form_field_path('category'), ignore_query: true)
    expect(page).to have_content 'Please add a short label.'
    expect(page).to have_css '#other_category.govuk-input--error[aria-describedby="other_category-error"]'

    fill_in 'Add a short label. You can explain it fully on the next page', with: 'Question about a tariff tool feature'
    click_button 'Continue'

    expect(page).to have_css 'h1', text: 'How can we help you?'
  end

  it 'marks the generic query textarea as invalid using GOV.UK error attributes' do
    visit product_experience_enquiry_form_path

    choose 'Import duties and quotas'
    click_button 'Continue'
    click_button 'Continue'

    expect(page).to have_content 'Please explain how we can help.'
    expect(page).to have_css '#query.govuk-textarea--error[aria-describedby="query-hint query-error query-info"]'
  end

  it 'preserves the draft when the API submission fails' do
    allow(EnquiryForm).to receive(:create!)
      .and_return({ 'resource_id' => nil })

    visit product_experience_enquiry_form_path

    choose 'Import duties and quotas'
    click_button 'Continue'
    fill_in 'How can we help you?', with: 'I need help understanding duties.'
    click_button 'Continue'
    fill_in 'Email address', with: 'trader@example.com'
    click_button 'Continue'
    click_button 'Submit'

    expect(page).to have_current_path(product_experience_enquiry_form_check_your_answers_path, ignore_query: true)
    expect(page).to have_content 'There was a problem submitting your enquiry. Please try again later.'
    expect(page).to have_content 'I need help understanding duties.'
    expect(page).to have_content 'trader@example.com'
  end

  it 'restarts the journey when an active draft has expired' do
    visit product_experience_enquiry_form_path

    cache_store.clear
    visit product_experience_enquiry_form_check_your_answers_path

    expect(page).to have_current_path(product_experience_enquiry_form_path, ignore_query: true)
    expect(page).to have_css 'h1', text: 'What do you need help with?'
  end

  def large_answer(prefix)
    "#{prefix}. #{'Extra detail ' * 350}"
  end

  def session_cookie_value
    if page.driver.respond_to?(:cookies)
      page.driver.cookies.fetch('_tradetarifffrontend_session').value
    else
      page.driver.browser.current_session.cookie_jar.to_hash.fetch('_tradetarifffrontend_session')
    end
  end
end
