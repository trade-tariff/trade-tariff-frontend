RSpec.shared_examples 'a resource that has attributes' do |attributes|
  subject(:resource) { described_class.new(attributes) }

  describe 'implemented attributes' do
    attributes.each do |attribute_key, attribute_value|
      it "defines an accessor for #{attribute_key}" do
        expect(resource.public_send(attribute_key)).to eq(attribute_value)
      end
    end
  end
end
