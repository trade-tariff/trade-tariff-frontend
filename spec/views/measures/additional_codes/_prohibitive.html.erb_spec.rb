require 'spec_helper'

RSpec.describe 'measures/additional_codes/_prohibitive', type: :view do
  let(:measure) do
    build(:measure, :prohibitive, :with_additional_code)
  end

  before do
    render 'measures/additional_codes/prohibitive', measure: MeasurePresenter.new(measure)
  end

    context 'when residual returns true' do
      let(:measure) { build(:measure, :residual) }

      it { expect(rendered).to match(/Control does not apply to goods/) }

      it { expect(rendered).to match(measure.additional_code.code) }

      it { expect(rendered).to match(measure.additional_code.formatted_description) }
    end

    context 'when residual returns false' do
      let(:measure) { build(:measure, :with_additional_code) }

      it { expect(rendered).to match(/Control applies to goods/) }

      it { expect(rendered).to match(measure.additional_code.code) }

      it { expect(rendered).to match(measure.additional_code.formatted_description) }
    end
end
