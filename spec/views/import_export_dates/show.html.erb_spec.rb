RSpec.describe 'import_export_dates/show.html.erb', type: :view do
  subject { render }

  before { assign :import_export_date, import_export_date }

  let(:import_export_date) do
    ImportExportDate.new(
      'import_date(3i)' => '1',
      'import_date(2i)' => '2',
      'import_date(1i)' => '2021',
    )
  end

  describe 'header' do
    it { is_expected.to have_css 'header span', text: /UK Integrated/ }
  end
end
