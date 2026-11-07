require 'spec_helper'

RSpec.describe GuidedSearch::ImageDescriptionToken do
  let(:id) { SecureRandom.uuid }
  let(:token) { described_class.issue(id:, session_id: 'session-one') }

  it 'accepts the original session and job' do
    expect(described_class.valid?(token, id:, session_id: 'session-one')).to be true
  end

  it 'rejects a different session' do
    expect(described_class.valid?(token, id:, session_id: 'session-two')).to be false
  end

  it 'rejects a different job' do
    expect(described_class.valid?(token, id: SecureRandom.uuid, session_id: 'session-one')).to be false
  end

  it 'rejects a different service' do
    grant = token
    TradeTariffFrontend::ServiceChooser.with_source('xi') do
      expect(described_class.valid?(grant, id:, session_id: 'session-one')).to be false
    end
  end

  it 'rejects expired grants' do
    grant = token
    travel 6.minutes do
      expect(described_class.valid?(grant, id:, session_id: 'session-one')).to be false
    end
  end
end
