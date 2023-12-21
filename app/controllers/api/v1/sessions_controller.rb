# frozen_string_literal: true

class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_action :authenticate_request, only: [:login, :refresh_token]

  def login
    user = User.find_by_email(signin_params[:email])
    if user&.authenticate(signin_params[:password])
      render_json('Sign in successfully', { email: user.email, token: user.generate_access_token, refresh_token: user.generate_refresh_token })
    else
      render json: { status: 'Non-Authoritative Information', message: ['You entered in an incorrect email or password,please try again.'], data: [], status_code: 203, messageType: 'error' },
             status: 203
    end
  end

  def logout
    token = request.headers['Authorization']&.split(' ')&.last
    if token.present?
      user = current_user
      BlackliastToken.find_or_create_by(user_id: user.id, token:)
      user.update(refresh_token: nil)
      render_json('Logout Successfully!')
    else
      render_401
    end
  end

  def logined_user
    user = current_user.attributes.except("password_digest", "refresh_token", "created_at", "updated_at")
    render_json("Current User fetched successfully", { user: user })
  end

  def refresh_token
    begin
      return render_400("Refresh token not found!") unless signin_params[:refresh_token].present?

      decoded_token = jwt_decode(signin_params[:refresh_token])
      user = User.find_by(id: decoded_token[:user_id])

      return render_400("Invalid Refresh token!") unless user.present?
      render_json("Token genrated successfully!", { token: user.generate_access_token, refresh_token: user.generate_refresh_token })
    rescue => e
      render_400(e.message)
    end
  end

  private

  def signin_params
    params.require(:user).permit(:email, :password, :refresh_token)
  end
end
