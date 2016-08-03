class Api::SessionsController < Devise::SessionsController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  skip_before_action :verify_signed_out_user

  before_action :ensure_params_exist, only: [:create, :destroy]

  respond_to :json

  def create
    user = User.find_for_database_authentication phone_number: user_params[:phone_number]
    return invalid_login_attempt unless user

    if user.valid_password? user_params[:password]
      sign_in user, store: false
      user.update_attributes signed_in: true
      render json: {auth_token: user.authentication_token, phone_number: user.phone_number},
        status: :ok
      return
    end
    invalid_login_attempt
  end

  def destroy
    user = User.find_for_database_authentication phone_number: user_params[:phone_number]
    if user.signed_in? && user.authentication_token == user_params[:authentication_token]
      sign_out user
      render json: {}, status: :ok
    else
      render json: {message: t("api.invalid_token")}, status: 401
    end
  end

  protected
  def ensure_params_exist
    return unless params[:user].blank?
    render json: {error: t("api.missing_params")}, status: 422
  end

  def invalid_login_attempt
    render json: {error: t("api.sign_in_fail")}, status: 401
  end

  private
  def user_params
    params.require(:user).permit :phone_number, :password, :authentication_token
  end
end
