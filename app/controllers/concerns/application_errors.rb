# frozen_string_literal: true

module ApplicationErrors
  extend ActiveSupport::Concern

  class DecodeError < StandardError; end
  class ExpiredSignature < StandardError; end

  included do # rubocop:disable Metrics/BlockLength
    # Rescue from missing parameter error
    rescue_from ActionController::ParameterMissing do |exception|
      render json: {
        status: 'Missing Parameter(s)',
        code: 422,
        errors: [],
        message: "One or more parameters are missing. #{exception}"
      }, status: 422
    end

    rescue_from ActionController::UnpermittedParameters do |exception|
      render json: {
        status: 'Unpermitted Parameter(s)',
        code: 422,
        errors: [],
        message: "One or more parameters are not permitted: #{exception}"
      }, status: 422
    end

    rescue_from ApplicationErrors::DecodeError do |_error|
      render json: {
        status: 'Unauthorized',
        code: 401,
        errors: [],
        message: 'Access denied!. Invalid token supplied.'
      }, status: 401
    end

    rescue_from ApplicationErrors::ExpiredSignature do |_error|
      render json: {
        status: 'Unauthorized',
        code: 401,
        errors: [],
        message: 'Access denied!. Token has expired.'
      }, status: 401
    end

    if Rails.env.production?
      rescue_from ArgumentError, with: :render_500
      rescue_from NoMethodError, with: :render_500
      rescue_from ::AbstractController::ActionNotFound, with: :render_500
      rescue_from ActiveRecord::RecordNotFound, with: :render_500
      rescue_from ActionView::Template::Error, with: :render_500
    end
  end

  protected

  def render_json(msg, data = [])
    render json: { status: 'OK', message: [msg], data:, status_code: 200, messageType: 'success' }, status: 200
  end

  def render_422(msg)
    render json: { status: 'Unprocessable Entity', message: [msg].flatten, data: [], status_code: 422, messageType: 'error' },
           status: 422
  end

  def render_400(msg)
    render json: { status: 'Bad Request', message: [msg], data: [], status_code: 400, messageType: 'error' },
           status: 400
  end

  def render_404(msg = "The requested endpoint doesn't exist")
    render json: { status: 'Not Found', message: [msg], data: [], status_code: 404, messageType: 'error' },
           status: 404
  end

  def render_500
    render json: { status: 'Internal Server Error', message: ['Something went wrong, please try after some time'], data: [], status_code: 500, messageType: 'error' },
           status: 500
  end

  def render_401(message = 'You are not authorized')
    render json: { status: 'Unauthorized', message: [message], data: [], status_code: 401, messageType: 'error' },
           status: 401
  end
end
