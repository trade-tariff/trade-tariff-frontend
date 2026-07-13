require 'spec_helper'

RSpec.describe 'basic_sessions/new', type: :view do
  subject(:rendered_page) { render && rendered }

  before do
    # Route is only drawn when BASIC_PASSWORD is present at boot (not in test).
    without_partial_double_verification do
      allow(view).to receive(:basic_sessions_path).and_return('/basic_sessions')
    end

    assign :basic_session, BasicSession.new(return_url: '/')
  end

  it { is_expected.to have_css 'h1', text: /non-production Online Trade Tariff/ }

  # govuk_design_system_formbuilder only puts label text on the button when
  # show_password_text is passed. Without it the GOV.UK JS unhides an empty
  # secondary button (thin grey bar) because setType early-returns when the
  # input is already type=password.
  # visible: :all / :hidden — the toggle is server-rendered with [hidden]
  # until GOV.UK Frontend JS runs.
  it 'renders the show password toggle with visible label text' do
    expect(rendered_page).to have_css(
      'button.govuk-password-input__toggle',
      text: 'Show',
      visible: :all,
    )
  end

  it 'keeps the show password toggle hidden until JS initialises' do
    expect(rendered_page).to have_css(
      'button.govuk-password-input__toggle[hidden]',
      text: 'Show',
      visible: :hidden,
    )
  end
end
