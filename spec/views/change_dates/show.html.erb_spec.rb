RSpec.describe 'change_dates/show.html.erb', type: :view do
  subject { render }

  before { assign :change_date, change_date }

  let(:change_date) do
    ChangeDate.new(
      'import_date(3i)' => '1',
      'import_date(2i)' => '2',
      'import_date(1i)' => '2021',
    )
  end

  describe 'header' do
    it { is_expected.to have_css 'header span', text: /UK Integrated/ }
  end
end
