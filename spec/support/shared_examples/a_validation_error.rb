RSpec.shared_examples 'a validation error' do |message|
  it 'shows there is a problem' do
    expect(page).to have_css 'h2', text: 'There is a problem'
  end

  it 'shows the validation error message' do
    expect(page).to have_content message
  end
end
