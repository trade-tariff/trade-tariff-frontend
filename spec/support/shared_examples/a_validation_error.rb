RSpec.shared_examples 'a validation error' do |message|
  it 'shows there is a problem' do
    expect(page).to have_css 'h2', text: 'There is a problem'
  end

  it 'shows the validation error message' do
    expect(page).to have_content message
  end

  it 'has a back link to the previous step' do
    back_link = page.find_link('Back')
    expect(back_link[:href]).to eq(expected_back_path)
  end
end
