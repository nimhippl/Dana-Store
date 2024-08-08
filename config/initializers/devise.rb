Devise.setup do |config|
  require 'devise/orm/active_record'
  config.authentication_keys = [:telegram_chat_id]
  config.case_insensitive_keys = [:telegram_chat_id]
  config.strip_whitespace_keys = [:telegram_chat_id]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 12
  config.expire_all_remember_me_on_sign_out = true
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
