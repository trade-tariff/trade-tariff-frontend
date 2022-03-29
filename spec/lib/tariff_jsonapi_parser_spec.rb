require 'spec_helper'

RSpec.describe TariffJsonapiParser do
  describe '#parse' do
    let(:json) { JSON.parse file_fixture("jsonapi/#{json_file}.json").read }

    context 'with singular resource' do
      subject(:parse) { described_class.new(json).parse }

      context 'with valid' do
        let(:json_file) { 'singular_no_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }
      end

      context 'without attributes field' do
        let(:json_file) { 'singular_no_attributes' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.not_to include 'name' }
      end

      context 'with relationships' do
        let(:json_file) { 'singular_with_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }
        it { is_expected.to include 'parts' => [{ 'resource_type' => 'part', 'meta' => { 'foo' => 'bar' }, 'part_name' => 'A part name' }] }
      end

      context 'with valid missing relationship' do
        let(:json_file) { 'singular_valid_null_singular_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }
        it { is_expected.to include 'part' => nil }
      end

      context 'with missing relationships' do
        let(:json_file) { 'singular_missing_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }
        it { is_expected.to include 'parts' => [{}] }
      end

      context 'with invalid relationships' do
        let(:json_file) { 'singular_invalid_relationship' }

        it 'raises a description exception' do
          expect { parse }.to raise_exception \
            described_class::ParsingError,
            "Error finding relationship 'parts': nil"
        end
      end
    end

    context 'with array resource' do
      subject(:parse) { described_class.new(json).parse.first }

      context 'with valid' do
        let(:json_file) { 'multiple_no_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }
      end

      context 'with relationships' do
        let(:json_file) { 'multiple_with_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }
        it { is_expected.to include 'parts' => [{ 'resource_type' => 'part', 'meta' => { 'foo' => 'bar' }, 'part_name' => 'A part name' }] }
      end

      context 'with missing relationships' do
        let(:json_file) { 'multiple_missing_relationship' }

        it { is_expected.to include 'resource_type' => 'mock_entity' }
        it { is_expected.to include 'meta' => { 'foo' => 'bar' } }
        it { is_expected.to include 'name' => 'Joe' }
        it { is_expected.to include 'age' => 21 }
        it { is_expected.to include 'parts' => [{}] }
      end

      context 'with invalid relationships' do
        let(:json_file) { 'multiple_invalid_relationship' }

        it 'raises a description exception' do
          expect { parse }.to raise_exception \
            described_class::ParsingError,
            "Error finding relationship 'parts': nil"
        end
      end
    end
  end
end
