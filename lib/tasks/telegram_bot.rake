namespace :telegram do
  desc "Set webhook for Telegram bot"
  task set_webhook: :environment do
    bot = Telegram.bots[:default]
    webhook_url = "https://monitor-on-squirrel.ngrok-free.app/telegram/#{Digest::SHA256.hexdigest(bot.token)}"
    response = bot.set_webhook(url: webhook_url)
    puts "Setting webhook: #{response}"
  end
end
