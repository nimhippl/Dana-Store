require 'telegram/bot'
require 'net/http'
require 'uri'

class NewslettersController < ApplicationController
  def index
  end

  def create
    errors = []
    user = User.find_by(id: 7)
    if user && user.telegram_chat_id.present?
      begin
        phone_number = params[:phone_number]
        bank_name = params[:bank_name]
        file = params[:file]
        send_newsletter(user, phone_number, bank_name, file)
      rescue => e
        errors << "Ошибка в отправлении рассылки пользователю #{user.telegram_username} (#{user.telegram_chat_id}): #{e.message}"
        Rails.logger.error "Ошибка в отправлении рассылки: #{e.message}"
      end
    else
      errors << "Пользователь #{user&.telegram_username || 'unknown'} не имеет данных для отправки" if user
      errors << "Пользователь не найден" unless user
    end

    if errors.any?
      flash[:alert] = errors.join(", ")
    else
      flash[:notice] = "Рассылка создана и отправлена в Telegram"
    end
    redirect_to newsletters_path
  end

  private

  def send_newsletter(user, phone_number, bank_name, file)
    total_due = calculate_total_due(user)
    message = "Привет, #{user.telegram_username}! 👋\n\nПришло время оплатить заказы\nТвой текущий долг: #{total_due} ₽\nНомер телефона для перевода: #{phone_number}\nНазвание банка для перевода: #{bank_name}"
    send_telegram_message(user.telegram_chat_id, message)
    if file.present?
      send_telegram_photo(user.telegram_chat_id, file)
    end
  end


  def send_telegram_message(chat_id, message)
    token = Rails.application.credentials.dig(:telegram, :bot, :token)
    Telegram::Bot::Client.new(token).tap do |bot|
      bot.send_message(chat_id: chat_id, text: message)
    end
  end

  def send_telegram_photo(chat_id, file)
    token = Rails.application.credentials.dig(:telegram, :bot, :token)
    uri = URI("https://api.telegram.org/bot#{token}/sendPhoto")
    request = Net::HTTP::Post.new(uri)
    form_data = [['chat_id', chat_id], ['photo', File.open(file.tempfile.path)]]
    request.set_form form_data, 'multipart/form-data'
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  end

  def calculate_total_due(user)
    user.orders.where(state: 0).joins(:product).sum('products.price')
  end

end
