class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_user_info
  before_action :authenticate_user!, unless: :telegram_webhook_controller?
  before_action :set_locale

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:telegram_chat_id, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:telegram_chat_id, :password])
  end

  private

  def set_user_info
    @telegram_username = current_user.telegram_username if current_user
  end

  def set_locale
    I18n.locale = :ru
  end

  def telegram_webhook_controller?
    self.class.name == 'TelegramWebhookController'
  end
end
