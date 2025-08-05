RSpec.describe EnquiryForm do
  describe '.create!' do
    subject(:response) { described_class.create!(attributes) }

    let(:reference_number) { 'R1M5X8LU' }
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
          .and_return(jsonapi_response(:enquiry_form_submission, { reference_number: reference_number }))
      end

      it { is_expected.to be_a described_class }

      it 'returns the reference number' do
        expect(response['reference_number']).to eq(reference_number)
      end
    end

    context 'when the request fails' do
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
          .and_raise(Faraday::ClientError.new('Unprocessable Entity'))
      end

      it 'returns nil' do
        expect(response).to be_nil
      end
    end
  end
end
