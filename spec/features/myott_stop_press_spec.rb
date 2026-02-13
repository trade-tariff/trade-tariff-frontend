require 'spec_helper'

RSpec.describe 'Myott stop press subscription', type: :feature do
  include_context 'with cached chapters'

  describe 'new subscriber' do
    let(:user) do
      build(:user,
            subscriptions: [])
    end

    let(:updated_user) do
      build(:user,
            subscriptions: [
              { 'id' => '123', 'subscription_type' => 'stop_press', 'active' => true },
            ])
    end
    let(:subscription) { build(:subscription, :stop_press) }

    before do
      allow(User).to receive(:find).and_return(user, updated_user)
      allow(User).to receive(:update).and_return(true)
      allow(Subscription).to receive(:find).and_return(nil, subscription)
    end

    describe 'subscribing to all chapters' do
      it 'allows a user to subscribe to all chapters' do
        visit myott_path
        expect(page).to have_content('Your tariff watch lists')
        click_link 'Create a Stop Press watch list'

        expect(page).to have_title('Set preferences')

        choose 'All tariff chapter updates'
        click_button 'Continue'

        expect(page).to have_content('You have selected all chapters')
        expect(page).to have_title('Review selection')

        find('span', text: 'Show chapters selected').click
        expect(page).to have_content(chapter1.to_s)
        expect(page).to have_content(chapter2.to_s)
        expect(page).to have_content(chapter3.to_s)

        click_button 'Continue'

        expect(page).to have_title('Stop Press watch list updated')
        expect(page).to have_content('You have updated your Stop Press watch list')
      end
    end

    describe 'subscribing to specific chapters' do
      it 'allows a user to subscribe to specific chapters' do
        visit myott_path
        expect(page).to have_content('Your tariff watch lists')
        click_link 'Create a Stop Press watch list'

        expect(page).to have_title('Set preferences')

        choose 'Select the tariff chapters I am interested in'
        click_button 'Continue'

        check 'chapter_01'
        check 'chapter_02'
        click_button 'Continue'

        expect(page).to have_content('You have selected 2 chapters')
        find('span', text: 'Show chapters selected').click
        expect(page).to have_content(chapter1.to_s)
        expect(page).to have_content(chapter2.to_s)
        expect(page).not_to have_content(chapter3.to_s)
        click_button 'Continue'

        expect(page).to have_content('You have updated your Stop Press watch list')
      end
    end

    describe 'subscribing with no selection' do
      it 'returns an error if no subscription option is selected' do
        visit myott_path
        click_link 'Create a Stop Press watch list'
        click_button 'Continue'
        expect(page).to have_title('Error: Set preferences | UK Online Trade Tariff')
        expect(page).to have_content('Select a subscription preference to continue')
        expect(page).to have_link('Select a subscription preference to continue', href: '#myott-stop-press-preference-form-preference-field')
      end
    end
  end

  describe 'returning subscriber' do
    let(:subscription_hash) do
      {
        'id' => '123',
        'uuid' => '123',
        'resource_id' => '123',
        'subscription_type' => 'stop_press',
        'active' => true,
      }
    end

    let(:user) do
      User.new(
        email: 'user@example.com',
        chapter_ids: chapter_ids,
        subscriptions: [subscription_hash],
      )
    end

    let(:subscription) do
      build(:subscription, :stop_press,
            meta: {
              published: { yesterday: 3 },
              chapters: chapter_ids.present? ? chapter_ids.split(',').length : 0,
            })
    end

    before do
      allow(User).to receive_messages(update: true)
      allow(User).to receive(:find).with(nil, any_args).and_return(user)
      allow(Subscription).to receive(:find).and_return(subscription)
    end

    context 'with selected chapters' do
      let(:chapter_ids) { '01,02' }

      it 'shows the user their current subscription' do
        visit myott_path
        expect(page).to have_content('Your tariff watch lists')
        click_link 'View Stop Press watch list'

        expect(page).to have_title('Manage subscription')

        expect(page).to have_content('Manage your subscription')
        expect(page).to have_content('You have selected 2 chapters')

        find('span', text: 'Show chapters selected').click
        expect(page).to have_content(chapter1.to_s)
        expect(page).to have_content(chapter2.to_s)
        expect(page).not_to have_content(chapter3.to_s)
      end
    end

    context 'with all chapters' do
      let(:chapter_ids) { '' }

      it 'shows the user their current subscription' do
        visit myott_path
        click_link 'View Stop Press watch list'

        expect(page).to have_content('Manage your subscription')
        expect(page).to have_content('You have selected all chapters')

        find('span', text: 'Show chapters selected').click
        expect(page).to have_content(chapter1.to_s)
        expect(page).to have_content(chapter2.to_s)
        expect(page).to have_content(chapter3.to_s)
      end
    end
  end
end
