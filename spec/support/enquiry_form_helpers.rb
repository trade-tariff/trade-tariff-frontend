module EnquiryFormHelpers
  def start_enquiry
    visit product_experience_enquiry_form_path
    expect(page).to have_css 'h1', text: 'Trade tariff enquiry form'
    click_link 'Start'
  end

  def fill_in_full_name(name: 'John Doe')
    expect(page).to have_css 'label', text: 'Full name'
    expect(page).to have_field 'Full name'
    fill_in 'Full name', with: name
    click_button 'Continue'
  end

  def fill_in_company_name(company: 'Acme')
    expect(page).to have_css 'label', text: 'Company name (optional)'
    expect(page).to have_field 'Company name'
    fill_in 'Company name', with: company
    click_button 'Continue'
  end

  def fill_in_job_title(title: 'Director')
    expect(page).to have_css 'label', text: 'Job title (optional)'
    expect(page).to have_field 'Job title'
    fill_in 'Job title', with: title
    click_button 'Continue'
  end

  def fill_in_email(email: 'john.doe@acme.com')
    expect(page).to have_css 'label', text: 'Email address'
    expect(page).to have_field 'Email address'
    expect(page).to have_selector :id, 'email_address-hint', text: "We'll only use this to contact you about your enquiry."
    fill_in 'Email address', with: email
    click_button 'Continue'
  end

  def choose_category(category: 'category_quotas')
    expect(page).to have_css 'legend', text: 'What do you need help with?'
    expect(page).to have_selector :id, 'category-hint', text: 'Select one option'
    choose category if category
    click_button 'Continue'
  end

  def fill_in_query(query: 'I need to know my quotas')
    expect(page).to have_css 'label', text: 'How can we help?'
    expect(page).to have_selector :id, 'query-hint', text: "Explain what problem you're having and what help you need to resolve it."
    fill_in 'query', with: query
    click_button 'Continue'
  end
end
