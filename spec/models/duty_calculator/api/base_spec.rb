RSpec.describe DutyCalculator::Api::Base, :user_session do
  let(:user_session) { build(:duty_calculator_user_session) }

  before do
    allow(Rails.application.config.duty_calculator_http_client_uk).to receive(:retrieve).and_call_original
    allow(Rails.application.config.duty_calculator_http_client_xi).to receive(:retrieve).and_call_original
  end

  describe '#initialize' do
    context 'when initialized with unknown attributes' do
      subject(:resource) { DutyCalculator::Api::Measure.new(foo: :bar) }

      it { expect { resource }.not_to raise_error }
      it { expect(resource).not_to respond_to(:foo) }
    end

    context 'when initialized with known attributes' do
      subject(:resource) { DutyCalculator::Api::Measure.new(id: :bar) }

      it { expect(resource.id).to eq(:bar) }
    end
  end

  describe '#build' do
    subject(:api_resource) { DutyCalculator::Api::Commodity }

    let(:id) { '0103921100' }
    let(:query) { { foo: :bar } }

    context 'when the service is uk' do
      let(:service) { 'uk' }

      it 'calls the uk client with the correct params' do
        api_resource.build(service, id, query)

        expect(Rails.application.config.duty_calculator_http_client_uk).to have_received(:retrieve).with('commodities/0103921100.json', 'as_of' => Time.zone.today.iso8601, foo: :bar)
      end
    end

    context 'when the service is xi' do
      let(:service) { 'xi' }

      it 'calls the xi client with the correct params' do
        api_resource.build(service, id, query)

        expect(Rails.application.config.duty_calculator_http_client_xi).to have_received(:retrieve).with(
          'commodities/0103921100.json',
          'as_of' => Time.zone.today.iso8601,
          foo: :bar,
        )
      end
    end

    context 'when the session defines an import date' do
      let(:user_session) { build(:duty_calculator_user_session, import_date: '2021-10-08') }
      let(:service) { 'xi' }

      it 'calls the xi client with the correct params' do
        api_resource.build(service, id, query)

        expect(Rails.application.config.duty_calculator_http_client_xi).to have_received(:retrieve).with(
          'commodities/0103921100.json',
          'as_of' => Date.parse('2021-10-08').iso8601,
          foo: :bar,
        )
      end
    end
  end

  describe '#build_collection' do
    subject(:api_resource) { DutyCalculator::Api::GeographicalArea }

    let(:service) { 'uk' }
    let(:klass_override) { nil }
    let(:query) { { foo: :bar } }

    context 'when the service is uk' do
      let(:service) { 'uk' }

      it 'calls the uk client with the correct params' do
        api_resource.build_collection(service, klass_override, query)

        expect(Rails.application.config.duty_calculator_http_client_uk).to have_received(:retrieve).with(
          'geographical_areas.json',
          'as_of' => Time.zone.today.iso8601,
          foo: :bar,
        )
      end
    end

    context 'when the service is xi' do
      let(:service) { 'xi' }

      it 'calls the xi client with the correct params' do
        api_resource.build_collection(service, klass_override, query)

        expect(Rails.application.config.duty_calculator_http_client_xi).to have_received(:retrieve).with(
          'geographical_areas.json',
          'as_of' => Time.zone.today.iso8601,
          foo: :bar,
        )
      end
    end

    context 'when providing a klass override' do
      let(:klass_override) { 'Country' }

      it 'calls the uk client with the correct params' do
        api_resource.build_collection(service, klass_override, query)

        expect(Rails.application.config.duty_calculator_http_client_uk).to have_received(:retrieve).with(
          'geographical_areas/countries.json',
          'as_of' => Time.zone.today.iso8601,
          foo: :bar,
        )
      end
    end

    context 'when the session defines an import date' do
      let(:user_session) { build(:duty_calculator_user_session, import_date: '2021-10-08') }
      let(:service) { 'xi' }

      it 'calls the xi client with the correct params' do
        api_resource.build_collection(service, klass_override, query)

        expect(Rails.application.config.duty_calculator_http_client_xi).to have_received(:retrieve).with(
          'geographical_areas.json',
          'as_of' => Date.parse('2021-10-08').iso8601,
          foo: :bar,
        )
      end
    end
  end
end
