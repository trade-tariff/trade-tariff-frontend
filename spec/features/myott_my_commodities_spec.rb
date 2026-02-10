require 'spec_helper'

RSpec.describe 'Myott my commodities subscription', type: :feature do
  let(:subscription_hash) do
    {
      'id' => '123',
      'subscription_type' => 'my_commodities',
      'active' => true,
    }
  end

  let(:new_user) { build(:user, subscriptions: []) }
  let(:subscribed_user) { build(:user, subscriptions: [subscription_hash]) }
  let(:subscription) { build(:subscription, :my_commodities) }

  describe 'new subscriber' do
    before do
      allow(User).to receive(:find).and_return(new_user, new_user, subscribed_user)
      allow(User).to receive(:update).and_return(true)
      allow(Subscription).to receive(:find).and_return(nil, subscription)
      allow(Subscription).to receive(:batch).and_return(true)
    end

    describe 'creating a commodity watch list' do
      def go_to_upload_page
        visit myott_path
        expect(page).to have_content('Your tariff watch lists')
        click_link 'Create a commodity watch list'
        expect(page).to have_title('Upload commodities')
      end

      it 'allows user to create a commodity watch list for the first time' do
        go_to_upload_page
        attach_file 'fileUpload1', Rails.root.join('spec/fixtures/myott/mycommodities_files/valid_csv_file.csv')
        click_button 'Continue'
        expect(page).to have_content('Commodity code watch list created')
        click_link 'View your commodity watch list'
        expect(page).to have_content('Your commodity watch list')
      end

      it 'returns an error if there is no file attached' do
        go_to_upload_page
        click_button 'Continue'
        expect(page).to have_content('Select a file in a CSV or XLSX format')
      end

      it 'returns an error if the file type is invalid' do
        go_to_upload_page
        attach_file 'fileUpload1', Rails.root.join('spec/fixtures/myott/mycommodities_files/invalid_file_type.xls')
        click_button 'Continue'
        expect(page).to have_content('Selected file must be in a CSV or XLSX format')
      end

      it 'returns an error if there are no commodity codes in the file' do
        go_to_upload_page
        attach_file 'fileUpload1', Rails.root.join('spec/fixtures/myott/mycommodities_files/invalid_csv_file.csv')
        click_button 'Continue'
        expect(page).to have_content('Selected file has no valid commodity codes in column A')
      end
    end
  end

  describe 'returning subscriber' do
    let(:targets) do
      target_collection = build_list(:subscription_target, 1)
      build(:kaminari, collection: target_collection)
    end

    def go_to_watch_list
      visit myott_path
      expect(page).to have_content('Your tariff watch lists')
      click_link 'View commodity watch list'
      expect(page).to have_title('Commodity Watch List')
      expect(page).to have_content('Your commodity watch list')
    end

    def go_to_active_commodities
      go_to_watch_list
      click_link '3', href: active_myott_mycommodities_path
      expect(page).to have_title('Active commodities')
      expect(page).to have_content('Active commodities: 1')
    end

    describe 'updating a commodity watch list' do
      before do
        allow(User).to receive_messages(find: subscribed_user, update: true)
        allow(Subscription).to receive_messages(find: subscription, batch: true)
        allow(SubscriptionTarget).to receive(:all).and_return(targets)
      end

      it 'allows user to update a commodity watch list' do
        go_to_active_commodities
        click_link 'Replace all commodities (upload)'
        expect(page).to have_content('Replace all commodities')
        attach_file 'fileUpload1', Rails.root.join('spec/fixtures/myott/mycommodities_files/valid_csv_file.csv')
        click_button 'Continue'
        expect(page).to have_content('Commodity code watch list updated')
      end
    end

    describe 'unsubscribing from a commodity watch list' do
      before do
        allow(User).to receive_messages(find: subscribed_user, update: true)
        allow(Subscription).to receive_messages(find: subscription, delete: true)
      end

      it 'allows user to unsubscribe from a commodity watch list' do
        go_to_watch_list
        click_link 'Unsubscribe from commodity watch list'
        expect(page).to have_content('Are you sure you want to unsubscribe from your commodity watch list?')
        choose('yes')
        click_button 'Confirm'
        expect(page).to have_content('You have unsubscribed from your commodity watch list')
      end

      it 'returns to Your tariff watch lists if user declines to unsubscribe' do
        go_to_watch_list
        click_link 'Unsubscribe from commodity watch list'
        expect(page).to have_content('Are you sure you want to unsubscribe from your commodity watch list?')
        choose('no')
        click_button 'Confirm'
        expect(page).to have_content('Your commodity watch list')
      end

      it 'errors if user attempts to unsubscribe without selecting an option' do
        go_to_watch_list
        click_link 'Unsubscribe from commodity watch list'
        expect(page).to have_content('Are you sure you want to unsubscribe from your commodity watch list?')
        click_button 'Confirm'
        expect(page).to have_title('Error: Unsubscribe from commodity watch list | UK Online Trade Tariff')
        expect(page).to have_content('Select yes if you want to unsubscribe from your commodity watch list')
        expect(page).to have_link('Select yes if you want to unsubscribe from your commodity watch list', href: '#radio-buttons')
      end

      it 'errors if unsubscription fails' do
        allow(Subscription).to receive_messages(find: subscription, delete: false)
        go_to_watch_list
        click_link 'Unsubscribe from commodity watch list'
        expect(page).to have_content('Are you sure you want to unsubscribe from your commodity watch list?')
        choose('yes')
        click_button 'Confirm'
        expect(page).to have_content('There was an error unsubscribing you. Please try again.')
      end
    end

    describe 'when there are current measures changes in the tariff' do
      let(:as_of) { Date.current - 1.day }
      let(:measure_change) { build_paginated_measure_change.first }
      let(:grouped_measure_commodity_change) { build_paginated_measure_change.last }
      let(:measure_changes) { [measure_change] }

      def build_paginated_measure_change
        measure_change = build(
          :grouped_measure_change, :import, :with_uk_area,
          grouped_measure_commodity_changes: [attributes_for(:grouped_measure_commodity_change)]
        )

        paginated_children = build(:kaminari, collection: measure_change.grouped_measure_commodity_changes)
        measure_change.instance_variable_set(:@grouped_measure_commodity_changes, paginated_children)

        commodity_change = build(:grouped_measure_commodity_change)
        commodity_change.instance_variable_set(:@grouped_measure_change, measure_change)

        [measure_change, commodity_change]
      end

      before do
        allow(User).to receive(:find).and_return(subscribed_user)
        allow(Subscription).to receive(:find).and_return(subscription)
        allow(TariffChanges::GroupedMeasureChange).to receive_messages(all: measure_changes, find: measure_change)
        allow(TariffChanges::GroupedMeasureCommodityChange).to receive(:find).and_return(grouped_measure_commodity_change)

        go_to_watch_list
      end

      it 'has a link to download tariff changes as a spreadsheet' do
        expect(page).to have_link('Download tariff changes as spreadsheet', href: %r{/subscriptions/mycommodities/download\?as_of=#{as_of}})
      end

      it 'no commodity changes are shown' do
        heading = page.find('h4', text: 'Changes to your commodities:')
        expect(heading.sibling('p')).to have_content('No changes published')
      end

      it 'shows a measures table row with a 1 commodity link' do
        measures_heading = page.find('h4', text: 'Changes to your measures:')
        measures_table = measures_heading.sibling('table.govuk-table')

        within(measures_table) do
          expect(page).to have_css('td.govuk-table__cell', text: 'Import')
          expect(page).to have_link('1 commodity', href: %r{/subscriptions/grouped_measure_changes/.+\?as_of=#{as_of}})
        end
      end

      it 'drills down to the measure change' do
        click_link '1 commodity', href: %r{/subscriptions/grouped_measure_changes/.+\?as_of=#{as_of}}
        expect(page).to have_content('Imports from')
        expect(page).to have_content('Total commodities affected: 1')
        click_link '2 changes'
        expect(page).to have_selector('h1', text: 'Commodity: 1234567890')
        expect(page).to have_selector('h2', text: 'Trades affected')
        expect(page).to have_selector('h2', text: 'Preferential tariff quota')
      end
    end
  end
end
