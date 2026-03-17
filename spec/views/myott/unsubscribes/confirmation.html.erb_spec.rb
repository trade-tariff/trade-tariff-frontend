require 'spec_helper'

RSpec.describe 'myott/unsubscribes/confirmation.html.erb', type: :view do
  context 'when subscription type is stop_press' do
    before do
      assign(:title, 'You have unsubscribed')
      assign(:header, 'Unsubscribe successful')
      assign(:message, 'You will no longer receive these updates.')
      assign(:subscription_type, 'stop_press')
      render
    end

    it 'links "What did you think of this service?" to the in-app feedback path' do
      expect(rendered).to have_link('What did you think of this service?', href: feedback_path)
    end
  end
end
