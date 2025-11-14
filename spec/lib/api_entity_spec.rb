RSpec.describe ApiEntity do
  let :mock_entity do
    Class.new do
      include ApiEntity

      set_collection_path 'mock_entities'

      attr_accessor :name, :age

      has_many :parts, class_name: 'Part'
      has_one :part, class_name: 'Part'

      def self.name
        'MockEntity'
      end
    end
  end

  describe '#inspect' do
    context 'when initialized with attributes' do
      subject(:api_entity) { mock_entity.new(name: 'Bilbo Baggins', age: 111) }

      it { expect(api_entity.inspect).to eq('#<MockEntity name: "Bilbo Baggins", age: 111>') }
    end

    context 'when initialized without attributes and having them assigned separately' do
      subject(:api_entity) { mock_entity.new }

      before do
        api_entity.name = 'Hari Seldon'
        api_entity.age = 79
      end

      it { expect(api_entity.inspect).to eq('#<MockEntity name: "Hari Seldon", age: 79>') }
    end
  end

  describe '#resource_type' do
    subject(:resource_type) { mock_entity.new(attributes).resource_type }

    context 'when initialized with the resource type' do
      let(:attributes) { { resource_type: 'foo' } }

      it { is_expected.to eq('foo') }
    end

    context 'when initialized without the resource type' do
      let(:attributes) { {} }

      it { is_expected.to eq('mock_entity') }
    end
  end

  describe '#resource_id' do
    subject(:resource_id) { instance.resource_id }

    let(:instance) { mock_entity.new(resource_id: '123') }

    it { is_expected.to eq '123' }

    context 'when reassigning id' do
      let(:instance) do
        mock_entity.new(resource_id: '123').tap do |instance|
          instance.resource_id = '456'
        end
      end

      it { is_expected.to eq '123' }
    end
  end

  describe '#find' do
    subject(:request) { mock_entity.find(123) }

    before do
      stub_request(:get, "#{host}/mock_entities/123").and_return \
        status:,
        headers:,
        body:
    end

    let(:host) { TradeTariffFrontend::ServiceChooser.uk_host }
    let(:status) { 200 }
    let(:headers) { { 'content-type' => 'application/json; charset=utf-8' } }

    context 'with valid response' do
      let(:body) { file_fixture('jsonapi/singular_no_relationship.json').read }

      it { is_expected.to have_attributes resource_id: '123', name: 'Joe', age: 21 }
    end

    context 'with valid response and nil relationship' do
      let(:body) { file_fixture('jsonapi/singular_valid_null_singular_relationship.json').read }

      it { is_expected.to have_attributes resource_id: '123', name: 'Joe', age: 21, part: nil }
    end

    context 'with 400 response' do
      let(:status) { 400 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::BadRequestError }
    end

    context 'with 404 response' do
      let(:status) { 404 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::ResourceNotFound }
    end

    context 'with error response' do
      let(:status) { 500 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::ServerError }
    end

    context 'with 502 response' do
      let(:status) { 502 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::ServerError }
    end

    context 'with unparseable response' do
      let :body do
        file_fixture('jsonapi/singular_invalid_relationship.json').read
      end

      it 'raises descriptive exception' do
        expect { request }
          .to raise_exception UnparseableResponseError, %r{Error parsing #{host}/mock_entities/123 with headers:}
      end
    end
  end

  describe '#all' do
    subject(:request) { mock_entity.all }

    before do
      stub_request(:get, "#{host}/mock_entities").and_return \
        status:,
        headers:,
        body:
    end

    let(:host) { TradeTariffFrontend::ServiceChooser.uk_host }
    let(:status) { 200 }
    let(:headers) { { 'content-type' => 'application/json; charset=utf-8' } }

    context 'with valid response' do
      let(:body) { file_fixture('jsonapi/multiple_no_relationship.json').read }

      it { is_expected.to have_attributes length: 1 }
      it { expect(request.first).to have_attributes resource_id: '123', name: 'Joe', age: 21 }
    end

    context 'with 400 response' do
      let(:status) { 400 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::BadRequestError }
    end

    context 'with 404 response' do
      let(:status) { 404 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::ResourceNotFound }
    end

    context 'with error response' do
      let(:status) { 500 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::ServerError }
    end

    context 'with 502 response' do
      let(:status) { 502 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::ServerError }
    end

    context 'with unparseable response' do
      let :body do
        file_fixture('jsonapi/multiple_invalid_relationship.json').read
      end

      it 'raises descriptive exception' do
        expect { request }.to raise_exception UnparseableResponseError, %r{Error parsing #{host}/mock_entities with headers:}
      end
    end

    context 'with flaky connection' do
      let(:body) { file_fixture('jsonapi/multiple_no_relationship.json').read }

      context 'with one failure' do
        before do
          stub_request(:get, "#{host}/mock_entities")
            .to_timeout
            .then.to_return status:,
                            headers:,
                            body:
        end

        it 'retries' do
          expect(request).to have_attributes length: 1
        end
      end

      context 'with multiple failures' do
        before do
          stub_request(:get, "#{host}/mock_entities")
            .to_timeout
            .then.to_timeout
            .then.to_return status:,
                            headers:,
                            body:
        end

        it 'raises an exception' do
          expect { request }.to raise_exception Faraday::TimeoutError
        end
      end
    end
  end

  describe 'relationships' do
    let :parent_entity do
      Class.new do
        include ApiEntity
        has_many :components, class_name: 'Part'
      end
    end

    let :first_entity do
      Class.new(parent_entity) do
        set_collection_path 'first_entities'
        has_many :parts, class_name: 'Part'
        has_one :part, class_name: 'Part'

        def self.name
          'FirstEntity'
        end
      end
    end

    let :second_entity do
      Class.new(parent_entity) do
        set_collection_path 'second_entities'
        has_many :parts, class_name: 'Part'

        def self.name
          'SecondEntity'
        end
      end
    end

    before do # instantiate all entities
      first_entity
      second_entity
    end

    describe '.relationships' do
      context 'with ParentEntity' do
        subject { parent_entity.relationships }

        it { is_expected.to eql %i[components] }
      end

      context 'with FirstEntity' do
        subject { first_entity.relationships }

        it { is_expected.to eql %i[components parts part] }
      end

      context 'with SecondEntity' do
        subject { second_entity.relationships }

        it { is_expected.to eql %i[components parts] }
      end
    end

    describe 'instance relationships' do
      context 'with ParentEntity' do
        subject { parent_entity.new }

        it { is_expected.to respond_to :components }
        it { is_expected.to respond_to :components= }
        it { is_expected.not_to respond_to :parts }
        it { is_expected.not_to respond_to :parts= }
        it { is_expected.not_to respond_to :part }
        it { is_expected.not_to respond_to :part= }
      end

      context 'with FirstEntity' do
        subject { first_entity.new }

        it { is_expected.to respond_to :components }
        it { is_expected.to respond_to :components= }
        it { is_expected.to respond_to :parts }
        it { is_expected.to respond_to :parts= }
        it { is_expected.to respond_to :part }
        it { is_expected.to respond_to :part= }
      end

      context 'with SecondEntity' do
        subject { second_entity.new }

        it { is_expected.to respond_to :components }
        it { is_expected.to respond_to :components= }
        it { is_expected.to respond_to :parts }
        it { is_expected.to respond_to :parts= }
        it { is_expected.not_to respond_to :part }
        it { is_expected.not_to respond_to :part= }
      end
    end

    context 'with polymorphic relationships' do
      subject(:instance) { mock_entity.new(attributes) }

      before do
        stub_const 'Part', (Class.new do
          include ApiEntity

          attr_accessor :quantity, :name

          def self.name = 'Part'
        end)
      end

      let :attributes do
        {
          resource_type: 'parent_entity',
          vehicle_type: 'SUV',
          components: [
            {
              resource_type: 'part',
              name: 'steering wheel',
              quantity: 1,
            },
            {
              resource_type: 'part',
              name: 'seat',
              quantity: 4,
            },
          ],
          engine: {
            resource_type: 'part',
            name: 'petrol engine',
            quantity: 1,
          },
        }
      end

      context 'with explicit mappings' do
        let :mock_entity do
          Class.new do
            include ApiEntity
            has_many :components, polymorphic: { 'part' => 'Part' }
            has_one :engine, polymorphic: { 'part' => 'Part' }

            attr_accessor :vehicle_type

            def self.name = 'Car'
          end
        end

        it { is_expected.to have_attributes vehicle_type: 'SUV' }

        it { expect(instance.engine).to have_attributes name: 'petrol engine' }
        it { expect(instance.engine).to have_attributes quantity: 1 }

        it { expect(instance.components).to have_attributes length: 2 }

        it { expect(instance.components.first).to have_attributes name: 'steering wheel' }
        it { expect(instance.components.first).to have_attributes quantity: 1 }

        it { expect(instance.components.second).to have_attributes name: 'seat' }
        it { expect(instance.components.second).to have_attributes quantity: 4 }
      end

      context 'with unknown explicit types' do
        let :mock_entity do
          Class.new do
            include ApiEntity
            has_many :components, polymorphic: { 'component' => 'Part' }
            has_one :engine, polymorphic: { 'engine' => 'Part' }

            attr_accessor :vehicle_type

            def self.name = 'Car'
          end
        end

        it { expect { instance }.to raise_exception 'Unspecified polymorphic resource type' }
      end

      context 'with implicit mappings' do
        let :mock_entity do
          Class.new do
            include ApiEntity
            has_many :components, polymorphic: true
            has_one :engine, polymorphic: true

            attr_accessor :vehicle_type

            def self.name = 'Car'
          end
        end

        it { is_expected.to have_attributes vehicle_type: 'SUV' }

        it { expect(instance.engine).to have_attributes name: 'petrol engine' }
        it { expect(instance.engine).to have_attributes quantity: 1 }

        it { expect(instance.components).to have_attributes length: 2 }

        it { expect(instance.components.first).to have_attributes name: 'steering wheel' }
        it { expect(instance.components.first).to have_attributes quantity: 1 }

        it { expect(instance.components.second).to have_attributes name: 'seat' }
        it { expect(instance.components.second).to have_attributes quantity: 4 }
      end
    end
  end

  describe '#update' do
    subject(:result) do
      mock_entity.update(
        { name: 'Bilbo Baggins', age: 111 },
        { 'Authorization' => 'Bearer abc123' },
      )
    end

    let(:mock_response) { instance_double(Faraday::Response) }
    let(:parsed_data) { { name: 'Bilbo Baggins', age: 111 } }
    let(:api_double) { instance_double(Faraday::Connection, put: mock_response) }

    before do
      allow(mock_entity).to receive_messages(
        api: api_double,
        singular_path: '/api/uk/mock_entities/1',
      )
      allow(mock_entity).to receive(:parse_jsonapi).with(mock_response).and_return(parsed_data)
    end

    it 'returns an instance of the entity' do
      expect(result).to be_a(mock_entity)
    end

    it 'returns the correct name' do
      expect(result.name).to eq('Bilbo Baggins')
    end

    it 'returns the correct age' do
      expect(result.age).to eq(111)
    end
  end

  describe '#batch' do
    subject(:result) do
      mock_entity.batch(
        { targets: %w[1234567890 1234567891], subscription_type: 'my_commodities' },
        { authorization: 'Bearer abc123' },
      )
    end

    let(:mock_response) { instance_double(Faraday::Response) }
    let(:parsed_data) do
      {
        meta: {
          active: %w[1234567890],
          expired: %w[1234567891],
          invalid: [],
        },
      }
    end
    let(:api_double) { instance_double(Faraday::Connection, post: mock_response) }

    before do
      allow(mock_entity).to receive_messages(
        api: api_double,
        singular_path: '/api/uk/mock_entities/:id',
      )
      allow(mock_entity).to receive(:parse_jsonapi).with(mock_response).and_return(parsed_data)
    end

    it 'returns an instance of the entity' do
      expect(result).to be_a(mock_entity)
    end

    it { expect(result[:meta][:active]).to eq %w[1234567890] }
    it { expect(result[:meta][:expired]).to eq %w[1234567891] }
  end

  describe '#create!' do
    subject(:result) do
      mock_entity.create!(
        { name: 'Bilbo Baggins', age: 111 },
        { 'Content-Type' => 'application/json' },
      )
    end

    let(:mock_response) { instance_double(Faraday::Response) }
    let(:parsed_data) { { name: 'Bilbo Baggins', age: 111 } }
    let(:api_double) { instance_double(Faraday::Connection, post: mock_response) }

    before do
      allow(mock_entity).to receive_messages(
        api: api_double,
        singular_path: '/api/uk/mock_entities/1',
      )
      allow(mock_entity).to receive(:parse_jsonapi).with(mock_response).and_return(parsed_data)
    end

    it 'returns an instance of the entity' do
      expect(result).to be_a(mock_entity)
    end

    it 'returns the correct name' do
      expect(result.name).to eq('Bilbo Baggins')
    end

    it 'returns the correct age' do
      expect(result.age).to eq(111)
    end
  end

  describe '#delete' do
    subject(:result) { mock_entity.delete(123) }

    let(:mock_response) { instance_double(Faraday::Response, status: 200, body: nil) }
    let(:api_double) { instance_double(Faraday::Connection, delete: mock_response) }

    before do
      allow(mock_entity).to receive_messages(
        api: api_double,
        singular_path: '/api/uk/mock_entities/1',
      )
    end

    context 'when the delete request is successful' do
      it 'calls the delete endpoint with headers' do
        expect(result).to eq(mock_response)
      end

      it 'returns a 200 OK response' do
        expect(result.status).to eq(200)
      end

      it 'returns an empty body' do
        expect(result.body).to be_nil
      end
    end

    context 'when the delete request fails' do
      let(:mock_response) { instance_double(Faraday::Response, status: 500, body: nil) }

      it 'calls the delete endpoint with no headers' do
        expect(result).to eq(mock_response)
      end

      it 'returns a 500 OK response' do
        expect(result.status).to eq(500)
      end

      it 'returns an empty body' do
        expect(result.body).to be_nil
      end
    end
  end
end
