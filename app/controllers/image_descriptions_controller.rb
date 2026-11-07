class ImageDescriptionsController < ApplicationController
  RECOVERY_MESSAGE = 'We could not describe this image. Try again or enter a description.'.freeze
  UPLOAD_ERRORS = {
    413 => 'Choose an image smaller than 15MB.',
    415 => 'We could not use this image. Choose another image.',
    422 => 'We could not read this image. Choose another image.',
  }.freeze

  skip_before_action :set_path_info, :set_search, :bots_no_index_if_historical
  before_action :check_available

  rescue_from GuidedSearch::ImageDescription::InvalidResponse, with: :unavailable
  rescue_from Faraday::Error, with: :backend_error

  def create
    image = params[:image]
    unless image.is_a?(ActionDispatch::Http::UploadedFile) && (image.tempfile.is_a?(Tempfile) || image.tempfile.is_a?(File))
      return render json: { error: 'Choose one product image.' }, status: :unprocessable_content
    end
    return render json: { error: UPLOAD_ERRORS[413] }, status: :content_too_large if image.size > GuidedSearch::ImageDescription::MAX_BYTES
    return render json: { error: UPLOAD_ERRORS[422] }, status: :unprocessable_content if image.tempfile.stat.zero?

    session[:image_description] = true
    id = GuidedSearch::ImageDescription.submit(image)
    token = GuidedSearch::ImageDescriptionToken.issue(id:, session_id: session.id.public_id)
    render json: {
      status: 'queued',
      poll_url: image_description_path(id:, token:, day: nil, month: nil, year: nil),
    }, status: :accepted
  end

  def show
    return head :not_found unless GuidedSearch::ImageDescriptionToken.valid?(
      params[:token], id: params[:id], session_id: session.id&.public_id
    )

    payload = GuidedSearch::ImageDescription.find(params[:id])
    payload['error'] = RECOVERY_MESSAGE if payload['status'] == 'failed'
    render json: payload
  end

private

  def check_available
    response.headers['Cache-Control'] = 'no-store'
    head :not_found unless image_descriptions_enabled?
  end

  def backend_error(error)
    status = error.response_status
    return head :not_found if status == 404
    return render json: { error: UPLOAD_ERRORS[status] }, status: status if UPLOAD_ERRORS.key?(status)

    unavailable
  end

  def unavailable
    render json: { error: RECOVERY_MESSAGE }, status: :service_unavailable
  end
end
