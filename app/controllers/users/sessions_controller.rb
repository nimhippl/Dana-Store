class Users::SessionsController < Devise::SessionsController
  def new
    self.resource = resource_class.new
    clean_up_passwords(resource)
    yield resource if block_given?
    respond_with(resource, serialize_options(resource))
  end

  def create
    self.resource = User.find_by(telegram_chat_id: params[:user][:telegram_chat_id])
    if resource && resource.valid_password?(params[:user][:password]) && allowed_roles.include?(resource.roles.first.name)
      sign_in(resource_name, resource)
      redirect_to reports_path
    else
      self.resource = resource_class.new(sign_in_params)
      flash.now[:alert] = 'Invalid Telegram chat id or password'
      render :new
    end
  end

  private

  def sign_in_params
    params.require(:user).permit(:telegram_chat_id, :password, :remember_me)
  end

  def allowed_roles
    ['admin', 'manager']
  end
end
