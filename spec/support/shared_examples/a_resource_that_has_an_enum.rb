RSpec.shared_examples 'a resource that has an enum' do |field, enums|
  enums.each do |method_key, method_values|
    describe "##{method_key}?" do
      let(:method_name) { "#{method_key}?" }

      method_values.each do |method_value|
        subject(:resource) do
          described_class.new(field => method_value)
        end

        context "when the #{field} is set to #{method_value}" do
          it 'returns true' do
            expect(resource.public_send(method_name)).to be(true)
          end
        end
      end

      context "when the #{field} is set to nil" do
        subject(:resource) do
          described_class.new(field => nil)
        end

        it 'returns false' do
          expect(resource.public_send(method_name)).to be(false)
        end
      end

      context "when the #{field} is set to 'foo'" do
        subject(:resource) do
          described_class.new(field => 'foo')
        end

        it 'returns false' do
          expect(resource.public_send(method_name)).to be(false)
        end
      end
    end
  end
end
