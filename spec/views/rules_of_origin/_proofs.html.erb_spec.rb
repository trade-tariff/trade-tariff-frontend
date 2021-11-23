require 'spec_helper'

RSpec.describe 'rules_of_origin/_proofs.html.erb', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let(:render_page) do
    render 'rules_of_origin/proofs', proofs: proofs, scheme_title: nil
  end

  context 'with no proofs' do
    let(:proofs) { [] }

    it { is_expected.to have_css '.rules-of-origin__proofs', text: '' }
    it { is_expected.not_to have_css '.rules-of-origin__proofs__content' }
  end

  context 'with 1 proof' do
    let(:proofs) { build_list :rules_of_origin_proof, 1 }

    it { is_expected.to have_css '.rules-of-origin__proofs' }
    it { is_expected.to have_css 'p', text: /has the following proof/ }
    it { is_expected.to have_css '.rules-of-origin__proofs__content', count: 1 }
  end

  context 'with multiple proofs' do
    let(:proofs) { build_list :rules_of_origin_proof, 3 }

    it { is_expected.to have_css '.rules-of-origin__proofs' }
    it { is_expected.to have_css 'p', text: /has one of the following proofs/ }
    it { is_expected.to have_css '.rules-of-origin__proofs__content', count: 3 }
  end
end
