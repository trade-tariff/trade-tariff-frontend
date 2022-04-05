RSpec.describe 'measures/_measure_from_to', type: :view do
  subject { render_page && rendered }

  let(:render_page) { render 'measures/measure_from_to', measure: measure }

  context 'when the start date is nil' do
    let(:measure) { build :measure, effective_start_date: nil }

    it { is_expected.not_to have_css '.govuk-body' }
  end

  context 'when the start date is present' do
    let(:measure) { build :measure, effective_start_date: '2022-01-01' }

    it { is_expected.to have_css '.govuk-body' }
  end
end
