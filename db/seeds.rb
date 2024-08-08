['admin', 'manager', 'employee', 'guest'].each do |role_name|
  Role.find_or_create_by(name: role_name)
end

admin_role = Role.find_or_create_by(name: 'admin')

admin_user = User.create(telegram_chat_id: '@nim_hippl_bot') do |user|
  user.username = 'admin'
  user.password = '123456'
  user.password_confirmation = '123456'
  user.telegram_chat_id = '@nim_hippl_bot'
  user.telegram_username = '@hippoppoppi'
end

admin_user.save!

unless admin_user.roles.include?(admin_role)
  admin_user.roles << admin_role
end

Category.find_or_create_by(name: 'Прочее')
