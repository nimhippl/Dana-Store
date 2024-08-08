require Rails.root.join('app/services/telegram_service.rb')
class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :pending_requests, :archived, :activate, :destroy_all, :activate_all]

  def index
    @users = User.active
  end


  def pending_requests
    @users = User.pending.with_role('employee')
  end

  def destroy
    user = User.find(params[:id])
    user.update(status: :archived)
    user.destroy
  end

  def restore
    user = User.only_deleted.find(params[:id])
    user.restore
    user.update(status: :pending)
    redirect_to archived_users_users_path
  end

  def really_destroy
    user = User.only_deleted.find(params[:id])
    user.roles.clear
    user.really_destroy!
    redirect_to archived_users_users_path
  end


  def archived
    @users = User.only_deleted
  end

  def archived_show
    @user = User.only_deleted.find(params[:id])
  end

  def request_connection
    user = User.find(params[:user_id])
    user.update(status: :pending)
    send_telegram_message(user.telegram_chat_id, "Мы отправили запрос на подключение нашему офис-менеджеру. Пока ждешь уведомление о подключении, можешь выпить чашечку кофе ☕")
    redirect_to users_pending_requests_path, notice: "Запрос на подключение отправлен"
  end

  def activate
    user = User.find(params[:user_id])
    user.update(status: :active)
    message_text = "Поздравляем, менеджер одобрил твоё подключение!"
    send_telegram_message(user.telegram_chat_id, message_text)
    TelegramService.new(user.telegram_chat_id).send_menu_button
    redirect_to pending_requests_users_path, notice: "Пользователь подключен"
  end

  def destroy_all
    users = User.pending.with_role('employee')
    users.each do |user|
      user.update(status: :archived)
      user.destroy
    end
    redirect_to pending_requests_users_path, notice: "Все запросы на подключение удалены"
  end

  def activate_all
    users = User.pending.with_role('employee')
    users.each do |user|
      user.update(status: :active)
      message_text = "Поздравляем, менеджер одобрил твоё подключение!"
      send_telegram_message(user.telegram_chat_id, message_text)
      TelegramService.new(user.telegram_chat_id).send_menu_button
    end

    redirect_to pending_requests_users_path, notice: "Все пользователи подключены"
  end

  private

  def send_telegram_message(chat_id, message)
    TelegramService.new(chat_id).send_message(message)
  end
end
