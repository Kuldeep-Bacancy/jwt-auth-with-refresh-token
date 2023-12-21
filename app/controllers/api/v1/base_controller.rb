class Api::V1::BaseController < ApplicationController
  include JsonWebToken

  before_action :authenticate_request

  def authenticate_request
    token = request.headers['Authorization']&.split(' ')&.last
    begin
      return render_401 unless token.present?

      current_user_token(token)
    rescue => e
      render_400(e.message)
    end
  end

  def current_user_token(token)
    return render_401 if BlackliastToken.find_by(token:)

    decoded = jwt_decode(token)
    @current_user_id = decoded[:user_id]
  end

  def current_user
    @current_user ||= User.find_by(id: @current_user_id)
  end
end