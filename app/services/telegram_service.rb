class TelegramService
  def initialize(chat_id)
    @chat_id = chat_id
    @token = Rails.application.credentials.dig(:telegram, :bot, :token)
  end

  def send_message(text)
    Telegram::Bot::Client.new(@token).tap do |bot|
      bot.send_message(chat_id: @chat_id, text: text)
    end
  end

  def send_menu_button
    ngrok_url = Rails.application.credentials.dig(:telegram, :bot, :ngrok_url)
    kb = [
      [{ text: 'Открыть меню', web_app: { url: "#{ngrok_url}/web_app?chat_id=#{@chat_id}" } }]
    ]
    Telegram::Bot::Client.new(@token).tap do |bot|
      bot.send_message(chat_id: @chat_id, text: 'Открой меню, чтобы увидеть весь ассортимент:', reply_markup: { inline_keyboard: kb })
    end
  end
end