require 'spec_helper'

RSpec.describe TariffJsonapiParser do
  describe '#parse' do
    let(:json) { JSON.parse file_fixture("jsonapi/#{json_file}.json").read }

    context 'with singular resource' do
      subject(:parsed) { described_class.new(json).parse }

      context 'with valid' do
        let(:json_file) { 'singular_no_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'resource_id' => '123' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }
      end

      context 'without attributes field' do
        let(:json_file) { 'singular_no_attributes' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'resource_id' => '123' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.not_to include 'name' }
      end

      context 'with relationships' do
        let(:json_file) { 'singular_with_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'resource_id' => '123' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }

        it 'maps relationship data' do
          expect(parsed).to include 'parts' => [{
            'resource_type' => 'part',
            'resource_id' => '456',
            'meta' => { 'foo' => 'bar' },
            'part_name' => 'A part name',
          }]
        end
      end

      context 'with valid missing relationship' do
        let(:json_file) { 'singular_valid_null_singular_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'resource_id' => '123' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }
        it { is_expected.to include 'part' => nil }
      end

      context 'with missing relationships' do
        let(:json_file) { 'singular_missing_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'resource_id' => '123' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }
        it { is_expected.to include 'parts' => [{}] }
      end

      context 'with invalid relationships' do
        let(:json_file) { 'singular_invalid_relationship' }

        it 'raises a description exception' do
          expect { parsed }.to raise_exception \
            described_class::ParsingError,
            "Error finding relationship 'parts': nil"
        end
      end
    end

    context 'with array resource' do
      subject(:parsed) { described_class.new(json).parse.first }

      context 'with valid' do
        let(:json_file) { 'multiple_no_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'resource_id' => '123' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }
      end

      context 'with relationships' do
        let(:json_file) { 'multiple_with_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'resource_id' => '123' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }

        it 'maps relationship data' do
          expect(parsed).to include 'parts' => [{
            'resource_type' => 'part',
            'resource_id' => '456',
            'meta' => { 'foo' => 'bar' },
            'part_name' => 'A part name',
          }]
        end
      end

      context 'with missing relationships' do
        let(:json_file) { 'multiple_missing_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'resource_id' => '123' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }
        it { is_expected.to include 'parts' => [{}] }
      end

      context 'with invalid relationships' do
        let(:json_file) { 'multiple_invalid_relationship' }

        it 'raises a description exception' do
          expect { parsed }.to raise_exception \
            described_class::ParsingError,
            "Error finding relationship 'parts': nil"
        end
      end
    end

    context 'with a large included array referenced many times' do
      # Builds a response with 100 included resources and a data array of 50
      # items each referencing the same single included resource (id "1",
      # type "shared_thing"). This exercises both the O(1) index (finding
      # the right resource among 100) and the memoisation of its parsed form.
      subject(:parsed) { described_class.new(payload).parse }

      let(:shared_included_resource) do
        {
          'id' => '1',
          'type' => 'shared_thing',
          'attributes' => { 'label' => 'erga omnes' },
        }
      end

      let(:other_included_resources) do
        (2..100).map do |n|
          { 'id' => n.to_s, 'type' => 'shared_thing', 'attributes' => { 'label' => "other #{n}" } }
        end
      end

      let(:data_items) do
        (1..50).map do |n|
          {
            'id' => n.to_s,
            'type' => 'measure',
            'attributes' => { 'description' => "measure #{n}" },
            'relationships' => {
              'shared_thing' => { 'data' => { 'id' => '1', 'type' => 'shared_thing' } },
            },
          }
        end
      end

      let(:payload) do
        {
          'data' => data_items,
          'included' => [shared_included_resource] + other_included_resources,
        }
      end

      it 'resolves the shared relationship correctly for every data item' do
        expect(parsed).to all(include('shared_thing' => include('label' => 'erga omnes')))
      end

      it 'returns the identical parsed object for every reference to the same included resource' do
        # All 50 measures reference the same included resource. With memoisation
        # every call to find_and_parse_included for ["shared_thing","1"] must
        # return the exact same Ruby object (not just an equal one).
        shared_things = parsed.map { |item| item['shared_thing'] }
        first = shared_things.first
        expect(shared_things).to all(equal(first))
      end
    end
  end
end
