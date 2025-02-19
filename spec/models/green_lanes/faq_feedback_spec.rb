require 'spec_helper'

RSpec.describe GreenLanes::FaqFeedback, type: :model do
  let(:faq_feedback) { build(:green_lanes_faq_feedback) }

  describe '#send_feedback_to_backend' do
    let(:feedback_params) do
      {
        category_id: faq_feedback.category_id,
        question_id: faq_feedback.question_id,
        useful: faq_feedback.useful,
      }
    end
    let(:session_id) { faq_feedback.session_id }

    def mock_response(success:, status: nil, body: nil)
      instance_double(
        HTTPResponse,
        success?: success,
        status:,
        body:,
      )
    end

    context 'when the request is successful' do
      let(:response_double) { mock_response(success: true) }

      before do
        allow(faq_feedback.class).to receive(:post).and_return(response_double)
      end

      it 'returns true' do
        expect(faq_feedback.send_feedback_to_backend(feedback_params, session_id)).to be(true)
      end
    end

    context 'when the request fails' do
      let(:response_double) { mock_response(success: false, status: 500, body: 'Error') }

      before do
        allow(faq_feedback.class).to receive(:post).and_return(response_double)
        allow(Rails.logger).to receive(:warn)
      end

      it 'logs a warning' do
        faq_feedback.send_feedback_to_backend(feedback_params, session_id)
        expect(Rails.logger).to have_received(:warn).with('Failed to send feedback: 500 Error')
      end

      it 'returns false' do
        expect(faq_feedback.send_feedback_to_backend(feedback_params, session_id)).to be(false)
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(faq_feedback.class).to receive(:post).and_raise(StandardError.new('Unexpected failure'))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error' do
        begin
          faq_feedback.send_feedback_to_backend(feedback_params, session_id)
        rescue StandardError
          # Suppress the error propagation for testing the log
        end
        expect(Rails.logger).to have_received(:error).with(/Unexpected error when sending feedback/)
      end

      it 'returns false' do
        expect(faq_feedback.send_feedback_to_backend(feedback_params, session_id)).to be(false)
      end
    end
  end
end
