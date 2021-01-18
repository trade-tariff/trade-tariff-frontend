require 'spec_helper'

describe ChaptersController, 'GET to #show', type: :controller do
  let!(:section) { attributes_for(:section).stringify_keys }

  context 'with existing chapter id provided', vcr: { cassette_name: 'chapters#show' } do
    let!(:chapter)     { build :chapter, section: section }
    let!(:actual_date) { Date.today.to_s(:dashed) }

    before do
      get :show, params: { id: chapter.to_param }
    end

    it { is_expected.to respond_with(:success) }
    it { expect(assigns(:chapter)).to be_a(Chapter) }
    it { expect(assigns(:headings)).to be_a(Array) }
  end
end
