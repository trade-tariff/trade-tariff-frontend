RSpec.describe EnquiryForm do
  describe '.create!' do
    subject(:response) { described_class.create!(attributes) }

    let(:resource_id) { 'R1M5X8LU' }
    let(:attributes) { attributes_for(:enquiry_form) }

    context 'when the request is successful' do
      before do
        stub_api_request('enquiry_form/submissions', :post)
          .with(
            body: hash_including(
              data: {
                attributes: attributes,
              },
            ),
            headers: { 'Content-Type' => 'application/json' },
          )
          .and_return(jsonapi_response(:enquiry_form_submission, { resource_id: resource_id }))
      end

      it { is_expected.to be_a described_class }

      it 'returns the resource id' do
        expect(response['resource_id']).to eq(resource_id)
      end
    end
  end
end
