Telegram.bots_config = {
  default: {
    token: Rails.application.credentials.dig(:telegram, :bot, :token)
  }
}

session_store_path = Rails.root.join('tmp', 'sessions').to_s
Telegram::Bot::UpdatesController.session_store = :file_store, session_store_path, { expires_in: 1.month }
