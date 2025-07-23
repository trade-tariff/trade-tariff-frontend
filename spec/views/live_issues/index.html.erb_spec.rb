require 'spec_helper'

RSpec.describe 'live_issues/index', type: :view do
  subject { render }

  before do
    assign :live_issues, [
      build(
        :live_issue,
        updated_at: Time.zone.parse('2025-07-15'),
      ),
    ]
  end

  it { is_expected.to have_css 'th > div', text: '15 July 2025' }
  it { is_expected.to have_css 'h1#kramdown', text: 'Kramdown' }
  it { is_expected.to render_template 'live_issues/_commodities' }
end
