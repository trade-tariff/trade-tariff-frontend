require 'spec_helper'

RSpec.describe 'Myott my commodities subscription', type: :feature do
  describe 'new subscriber' do
    let(:user) do
      build(:user,
            subscriptions: [])
    end

    let(:updated_user) do
      build(:user,
            subscriptions: [
              { 'id' => '123', 'subscription_type' => 'my_commodities', 'active' => true },
            ])
    end
    let(:subscription) { build(:subscription, active: true, meta: { active: 1, expired: 1, invalid: 1 }) }

    before do
      allow(User).to receive(:find).and_return(user, user, updated_user)
      allow(User).to receive(:update).and_return(true)
      allow(Subscription).to receive(:find).and_return(nil, subscription)
      allow(Subscription).to receive(:batch).and_return(true)
    end

    describe 'creating a commodity watch list' do
      it 'allows user to create a commodity watch list for the first time' do
        visit myott_path
        expect(page).to have_content('Your tariff watch lists')
        click_link 'Create a commodity watch list'

        expect(page).to have_title('Upload commodities')

        attach_file 'fileUpload1', Rails.root.join('spec/fixtures/myott/mycommodities_files/valid_csv_file.csv')

        click_button 'Continue'

        expect(page).to have_content('Commodity code watch list created')

        click_link 'View your commodity watch list'

        expect(page).to have_content('Your commodity watch list')
      end

      it 'returns an error if there is no file attached' do
        visit myott_path
        expect(page).to have_content('Your tariff watch lists')
        click_link 'Create a commodity watch list'

        expect(page).to have_title('Upload commodities')

        click_button 'Continue'

        expect(page).to have_content('Please upload a file using the Choose file button or drag and drop.')
      end

      it 'returns an error if the file type is invalid' do
        visit myott_path
        expect(page).to have_content('Your tariff watch lists')
        click_link 'Create a commodity watch list'

        expect(page).to have_title('Upload commodities')

        attach_file 'fileUpload1', Rails.root.join('spec/fixtures/myott/mycommodities_files/invalid_file_type.txt')

        click_button 'Continue'

        expect(page).to have_content('Please upload a csv/excel file')
      end

      it 'returns an error if there are no commodity codes in the file' do
        visit myott_path
        expect(page).to have_content('Your tariff watch lists')
        click_link 'Create a commodity watch list'

        expect(page).to have_title('Upload commodities')

        attach_file 'fileUpload1', Rails.root.join('spec/fixtures/myott/mycommodities_files/invalid_csv_file.csv')

        click_button 'Continue'

        expect(page).to have_content('No commodities uploaded, please ensure valid commodity codes are in column A')
      end
    end
  end

  describe 'returning subscriber' do
    let(:user) do
      build(:user,
            subscriptions: [
              { 'id' => '123', 'subscription_type' => 'my_commodities', 'active' => true },
            ])
    end
    let(:subscription) { build(:subscription, active: true, meta: { active: 1, expired: 1, invalid: 1 }) }
    let(:targets) do
      target_collection = build_list(:subscription_target, 1)
      build(:kaminari, collection: target_collection)
    end

    before do
      allow(User).to receive_messages(find: user, update: true)
      allow(Subscription).to receive_messages(find: subscription, batch: true)
      allow(SubscriptionTarget).to receive(:all).and_return(targets)
    end

    describe 'updating a commodity watch list' do
      it 'allows user to update a commodity watch list' do
        visit myott_path
        expect(page).to have_content('Your tariff watch lists')
        click_link 'View commodity watch list'

        expect(page).to have_title('Commodity Watch List')

        expect(page).to have_content('Your commodity watch list')

        click_link '1', href: active_myott_mycommodities_path

        expect(page).to have_title('Active commodities')

        expect(page).to have_content('Active commodities: 1')

        click_link 'Replace all commodities (upload)'

        expect(page).to have_content('Replace all commodities')

        attach_file 'fileUpload1', Rails.root.join('spec/fixtures/myott/mycommodities_files/valid_csv_file.csv')

        click_button 'Continue'

        expect(page).to have_content('Commodity code watch list updated')
      end
    end
  end
end
