require 'spec_helper'

RSpec.describe 'Myott subscriptions', type: :feature do
  include_context 'with cached chapters'

  describe 'new subscriber' do
    let(:user) { build(:user, stop_press_subscription: false) }
    let(:updated_user) { build(:user, stop_press_subscription: true) }

    before do
      allow(User).to receive(:find).and_return(user, updated_user)
      allow(User).to receive(:update).and_return(true)
    end

    describe 'subscribing to all chapters' do
      it 'allows a user to subscribe to all chapters' do
        visit myott_path
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

        expect(page).to have_title('Subscription updated')
        expect(page).to have_content('You have updated your subscription')
      end
    end

    describe 'subscribing to specific chapters' do
      it 'allows a user to subscribe to specific chapters' do
        visit myott_path
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

        expect(page).to have_content('You have updated your subscription')
      end
    end
  end

  describe 'returning subscriber' do
    let(:user) { build(:user, chapter_ids:, stop_press_subscription: true) }

    before do
      allow(User).to receive_messages(find: user, update: true)
    end

    context 'with selected chapters' do
      let(:chapter_ids) { '01,02' }

      it 'shows the user their current subscription' do
        visit myott_path
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
